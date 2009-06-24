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

def shell_out(text)
  lines = text.split("\n").select {|line| line.strip != ''}
  lines.each do |line|
    raise "shell error with #{line}" unless system(line)
  end
end

class PackageDirectory < Hash
  def register(package)
    self[package.name] = package
  end

  def unregister(package)
    if package.class == Symbol
      self[package] = nil
    else
      self[package.name] = nil
    end
  end
end

class Defaults
  @@package_directory = PackageDirectory.new
  
  def self.package_directory 
    @@package_directory
  end
end

class Package
  attr_accessor :install_callback, :remove_callback, :installed_callback
  attr_accessor :name, :before_install_hooks, :after_install_hooks
  attr_accessor :before_remove_hooks, :after_remove_hooks

  def initialize(name, directory = Defaults.package_directory, dependency_names = [])
    @name = name
    @directory = directory
    @dependency_names = dependency_names

    @install_callback = $do_nothing
    @before_install_hooks = []
    @after_install_hooks = []

    @remove_callback = $do_nothing
    @before_remove_hooks = []
    @after_remove_hooks = []

    @installed_callback = $do_nothing
  end

  def install
    result = nil
    unless installed?
      run_install_hooks(:before)
      dependencies.each {|d| d.install}
      result = @install_callback.call
      run_install_hooks(:after)
    end
    result
  end

  def remove
    result = nil
    if installed?
      run_remove_hooks(:before)
      result = @remove_callback.call
      run_remove_hooks(:after)
    end
    result
  end

  def installed?
    @installed_callback.call
  end

  def add_install_hook(where, callback)
    case where
      when :before then @before_install_hooks << callback
      when :after then @after_install_hooks << callback
      else raise "where must be :before or :after"
    end
  end

  def add_remove_hook(where, callback)
    case where
    when :before then @before_remove_hooks << callback
    when :after then @after_remove_hooks << callback
    else raise "where must be :before or :after"
    end
  end

  def add_dependency(dependency)
    @dependency_names << dependency
  end

  def run_install_hooks(which = :all)
    case which
    when :before then @before_install_hooks.each {|h| h.call}
    when :after then @after_install_hooks.each {|h| h.call}
    when :all then 
      run_install_hooks(:before)
      run_install_hooks(:after)
    else raise "which must be :before|:after|:all"
    end
  end

  def run_remove_hooks(which = :all)
    case which
    when :before then @before_remove_hooks.each {|h| h.call}
    when :after then @after_remove_hooks.each {|h| h.call}
    when :all then 
      run_remove_hooks(:before)
      run_remove_hooks(:after)
    else raise "which must be :before|:after|:all"
    end    
  end

  def register
    @directory.register(self)
  end

  def unregister
    @directory.unregister(self)
  end

  def dependencies
    @dependency_names.map {|name| @directory[name]}
  end
end  

class Packages 
  def self.packages
    Defaults.package_directory
  end

  def self.install(name)
    packages[name].install
  end

  def self.remove(name)
    packages[name].remove
  end
end

class AptitudePackage < Package
  def initialize(name, aptitude_name, directory=Defaults.package_directory)
    super(name, directory, [])
    @aptitude_name = aptitude_name
    @install_callback = lambda {
      system("aptitude -y install #@aptitude_name")
    }
    @remove_callback = lambda {
      system("aptitude -y remove #@aptitude_name")
    }
    @installed_callback = lambda {
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
    @package.add_install_hook :before, block
  end

  def before_remove(&block)
    @package.add_remove_hook :before, block
  end

  def after_install(&block)
    @package.add_install_hook :after, block
  end

  def after_remove(&block)
    @package.add_remove_hook :after, block
  end
end

class MetaPackageBuilder
  attr_accessor :package
  
  def initialize(name)
    @package = Package.new(name)
    @directory = Defaults.package_directory
    @package.register
  end

  def is_one_of(*package_names)
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
    package_names.map {|name| @directory[name]}
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
