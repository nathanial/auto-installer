require 'graph'

def procedure(&block)
  lambda { block.call }
end

def do_nothing
  Proc.new {}
end

def package(name, kwargs)
  defaults = {:depends => [], :install => do_nothing,
              :remove => do_nothing, :installed? => do_nothing}
  kwargs = defaults.update(kwargs)
  dependencies = kwargs[:depends]
  p = Package.new(name, dependencies)
  p.install_callback = kwargs[:install]
  p.remove_callback = kwargs[:remove]
  p.installed_callback = kwargs[:installed?]
	puts "installed callback = #{p.installed_callback.class}"
  p.register
  return p
end

def meta_package(name, kwargs)
	package(name, kwargs)
end

def aptitude_package(name, aptitude_name)
  p = AptitudePackage.new(name, aptitude_name)
  p.register
  return p
end

def aptitude_packages(packages)
  names = packages.keys
  for name in names
    aptitude_package(name, packages[name])
  end
end

def add_install_hook(name, callback)
  package = Package.lookup(name)
  package.add_install_hook(callback)
end

class Package
  @@registered_packages = {}
  attr_accessor :install_callback, :remove_callback, :installed_callback  

  def initialize(name, dependencies = [])
    @name = name
    @dependencies = dependencies

    @install_callback = do_nothing
    @install_hooks = []

    @remove_callback = do_nothing
    @remove_hooks = []

    @installed_callback = do_nothing
  end

  def register
    @@registered_packages[@name] = self
  end

  def install
    unless installed?
      for dependency in @dependencies
        Package.install(dependency)
      end
      @install_callback.call
      run_install_hooks
    end
  end

  def remove
    if installed?
      @remove_callback.call
      run_remove_hooks
    end
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
		
    
