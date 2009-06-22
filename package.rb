require 'graph'

$do_nothing = lambda { false }

def procedure(&block)
  lambda { block.call }
end

def all(collection, predicate)
  collection.each {|c| return false unless predicate.call(c) }
  return true
end

def some(collection, predicate)
  collection.each {|c| return true if predicate.call(c) }
  return false
end

class Package
  @@registered_packages = {}
  attr_accessor :install_callback, :remove_callback, :installed_callback
  attr_accessor :dependencies
  
  def self.registered_packages 
    @@registered_packages
  end

  def initialize(name, dependencies = [])
    @name = name
    @dependencies = dependencies

    @install_callback = $do_nothing
    @install_hooks = []

    @remove_callback = $do_nothing
    @remove_hooks = []

    @installed_callback = $do_nothing
  end

  def register
    @@registered_packages[@name] = self
  end

  def self.clear_registered_packages
    @@registered_packages.clear
  end

  def install
    result = nil
    unless installed?
      for dependency in @dependencies
        Package.install(dependency)
      end
      result = @install_callback.call
      run_install_hooks
    end
    result
  end

  def remove
    result = nil
    if installed?
      result = @remove_callback.call
      run_remove_hooks
    end
    result
  end

  def installed?
    @installed_callback.call
  end

  def add_install_hook(callback)
    @install_hooks << callback
  end

  def add_remove_hook(callback)
    @remove_hooks << callback
  end

  def add_dependency(dependency)
    @dependencies << dependency
  end

  def run_install_hooks
    @install_hooks.each {|hook| hook.call}
  end

  def run_remove_hooks
    @remove_hooks.each {|hook| hook.call}
  end

  def dependency_graph(is_root = true)
    root = Node.new @name, @dependencies.map do |n|
      p = registered_packages[n] or raise "#{n} not registered"
      p.dependency_graph(false)
    end
    if is_root
      return Graph.new(root)
    else
      return root
    end
  end

  def self.lookup(name)
    p = @@registered_packages[name]
    if p.nil? 
      raise "cannot find package named #{name}"
    else
      return p
    end
  end

  def self.register(package)
    @@registered_packages[package.name] = package
  end

  def self.unregister(package)
    @@registered_packages[package.name] = nil
  end
  
  def self.install(name)
    lookup(name).install
  end

  def self.installed?(name)
    lookup(name).installed?
  end

  def self.remove(name)
    lookup(name).remove
  end

  def self.run_install_hooks(name)
    lookup(name).run_install_hooks
  end

  def self.run_remove_hooks(name)
    lookup(name).run_remove_hooks
  end
end  

class AptitudePackage < Package
  def initialize(name, aptitude_name)
    super(name, [])
    @aptitude_name = aptitude_name
    @install_callback = procedure {
      system("aptitude -y install #@aptitude_name")
    }
    @remove_callback = procedure {
      system("aptitude -y remove #@aptitude_name")
    }
    @installed_callback = procedure {
      search_results = `aptitude search #@aptitude_name`
      installed = search_results.reject {|r| not r =~ /^i/}
      not installed.empty?
    }
  end
end
		
class PackageBuilder
  attr_accessor :package
  
  def initialize(name)
    @package = Package.new(name)
    @package.register
  end
  
  def install(&block)
    @package.install_callback = block
  end

  def remove(&block)
    @package.remove_callback = block
  end
  
  def installed?(&block)
    @package.installed_callback = block
  end

  def depends_on(*args)
    if args.count == 1 and args.first.class == Array
      vector = args.first
      vector.each {|d| @package.add_dependency(d) }
    else 
      args.each {|d| @package.add_dependency(d) }
    end
  end

  def before_install(&block)
    @package.add_install_hook block
  end

  def before_remove(&block)
    @package.add_remove_hook block
  end
end

class MetaPackageBuilder
  attr_accessor :package
  
  def initialize(name)
    @package = Package.new(name)
    @package.register
  end

  def is_on_of(*package_names)
    @package.install_callback = lambda do
      packages = lookup_packages(package_names)
      if not some(packages, lambda {|p| p.installed?})
        packages.first.install
      end
    end
    @package.remove_callback = lambda do
      packages = lookup_packages(package_names)      
      packages.each {|p| p.remove}
    end
    @package.installed_callback = lambda do
      packages = lookup_packages(package_names)
      some(packages, lambda {|p| p.installed? })
    end
  end

  def consists_of(*package_names)
    @package.install_callback = lambda do
      packages = lookup_packages(package_names)
      packages.each {|p| p.install}
    end
    @package.remove_callback = lambda do
      packages = lookup_packages(package_names)
      packages.each {|p| p.remove}
    end
    @package.installed_callback = lambda do
      packages = lookup_packages(package_names)
      all(packages, lambda { |p| p.installed? })
    end
  end

  private 
  def lookup_packages(package_names)
    package_names.map {|name| Package.lookup(name)}
  end
end

def package(name, &block)
  builder = PackageBuilder.new(name)
  builder.instance_eval(&block)
  builder.package
end

def meta_package(name, &block)
  builder = MetaPackageBuilder.new(name)
  builder.instance_eval(&block)
  builder.package
end

def aptitude_packages(hash)
  names = hash.keys
  for name in names
    AptitudePackage.new(name, hash[name]).register
  end
end

def add_install_hook(name, &block)
  Package.lookup(name).add_install_hook(block)
end
