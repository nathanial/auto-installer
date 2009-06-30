require 'graph'
require 'erb'
require 'rexml/document'

$do_nothing = lambda { false }

SETTINGS = {}

def parse_settings 
  doc = REXML::Document.new(File.new(ENV['AUTO_INSTALLER_HOME'] + "/settings"))
  settings = doc.elements.first
  packages = settings.elements
  result = {}
  for p in packages
    properties = {}
    properties_elements = p.elements
    for e in properties_elements
      properties[e.attributes['name'].intern] = e.attributes['value']
    end
    SETTINGS[p.name.intern] = properties
  end
end

parse_settings
 
def shell_out(text)
  raise "shell error with #{text}" unless system(text)
end

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

class AbstractPackages
  def self.lookup_and_forward(*methods)
    if methods.count == 1 and methods.first.class == Array
      methods = methods.first
    end
      
    for method in methods
      self.class_eval("""
def self.#{method}(name)
  Packages.lookup(name).#{method}
end
""")
    end
  end
end

class Packages < AbstractPackages
  @@registered_packages = {}
  lookup_and_forward :install, :remove, :installed?
  lookup_and_forward :run_install_hooks, :run_remove_hooks
  
  class << self 
    def register(*args)
      if args.count == 1
        package = args[0]
        @@registered_packages[package.name] = package
      else 
        name = args[0]
        package = args[1]
        @@registered_packages[name] = package
      end
    end
    
    def unregister(package)
      @@registered_packages[package.name] = nil
    end
    
    def lookup(name)
      @@registered_packages[name]
    end
    
    def clear 
      @@registered_packages.clear
    end
    
    def count
      @@registered_packages.count
    end
  end
end

class Package
  attr_accessor :install_callback, :remove_callback, :installed_callback
  attr_accessor :name, :before_install_hooks, :after_install_hooks
  attr_accessor :before_remove_hooks, :after_remove_hooks

  def initialize(name, dependency_names = [])
    @name = name
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
    Packages.register(self)
  end

  def unregister
    Packages.unregister(self)
  end

  def dependencies
    @dependency_names.map {|name| Packages.lookup(name)}
  end
end  

class AptitudePackage < Package
  def initialize(name, aptitude_name)
    super(name, [])
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
    @name = name
    @home = ENV['AUTO_INSTALLER_HOME']
    @support = "#@home/support"
    @downloads = "#@home/downloads"
    @package = Package.new(name)
    @package.register
  end

  def process_support_files
    Dir.glob("#@support/#{@name.to_s}/*").each do |file|
      if File.file? file and /(\.*)(.erb$)/ =~ file
        fname = file.scan(/(.*)(.erb$)/)[0][0]
        File.open(fname, "w") do |f|
          f.write(ERB.new(File.read(file)).result)
        end
      end
    end
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

  def define(name, &block)
    (class << self; self; end).send :define_method, name, &block
  end
end

class MetaPackageBuilder < PackageBuilder
  attr_accessor :package
  
  def initialize(name)
    super(name)
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
    package_names.map {|name| Packages.lookup(name)}
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
