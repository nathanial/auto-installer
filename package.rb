require 'graph'
require 'erb'
require 'rexml/document'
require 'rubygems'
require 'aquarium'
require 'logging'
include Aquarium::Aspects
include Logging

SETTINGS = {}

GUARDS = {}
BEFORE_HOOKS = {}
AFTER_HOOKS = {}

def add_guard(options, &guard)
  command = options[:command]
  scope = options[:scope] || :all
  (GUARDS[[scope, command]] ||= []) << guard
end

def add_before_hook(options, &hook)
  command = options[:command]
  scope = options[:scope] || :all
  (BEFORE_HOOKS[[scope, command]] ||= []) << hook
end

def add_after_hook(options, &hook)
  command = options[:command]
  scope = options[:scope] || :all
  (AFTER_HOOKS[[scope, command]] ||= []) << hook
end

def guards_for(scope, command)
  return (GUARDS[[scope,command]] ||= []) + (GUARDS[[:all,command]] ||= [])
end

def after_hooks_for(scope, command)
  return (AFTER_HOOKS[[scope,command]] ||= []) + (AFTER_HOOKS[[:all,command]] ||= [])
end

def before_hooks_for(scope, command)
  return (BEFORE_HOOKS[[scope,command]] ||= []) + (BEFORE_HOOKS[[:all,command]] ||= [])
end

def parse_settings 
  if not ENV['AUTO_INSTALLER_HOME'].nil? 
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
end

parse_settings

def shell_out(text)
  info(text)
  raise "shell error with #{text}" unless system("#{text} > /dev/null")
end

def shell_out_force(text)
  info(text)
  system("#{text} > /dev/null")
end

def shell_out_verbose(text)
  info(text)
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

module ClassLevelInheritableAttributes
  def self.included(base)
    base.extend(ClassMethods)    
  end

  module ClassMethods
    def inheritable_attributes(*args)
      @inheritable_attributes ||= [:inheritable_attributes]
      @inheritable_attributes += args
      args.each do |arg|
        class_eval "class << self; attr_accessor :#{arg} end"
      end
      @inheritable_attributes
    end
    
    def inherited(subclass)
      @inheritable_attributes.each do |inheritable_attribute|
        instance_var = "@#{inheritable_attribute}" 
        subclass.instance_variable_set(instance_var, instance_variable_get(instance_var))
      end
    end
  end
end

class PackageNotFound < Exception; end

class Packages
  @@registered_packages = {}

  class << self 
    def registered_packages
      @@registered_packages
    end

    def register(*args)
      name = nil
      package = nil
      if args.count == 1
        package = args[0]
        name = package.name
      else 
        name = args[0]
        package = args[1]
      end
      unless (package.instance_of? AptitudePackage or 
              package.instance_of? GemPackage)
        package = package.new
      end
      debug "registering #{package} as #{name}"
      @@registered_packages[name] = package
    end
    
    def unregister(package)
      @@registered_packages[package.name] = nil
    end
    
    def lookup(name)
      p = @@registered_packages[name]
      if not p
        raise PackageNotFound.new("cannot find package name \"#{name}\"")
      end
      return p
    end
    
    def clear 
      @@registered_packages.clear
    end
    
    def count
      @@registered_packages.count
    end

    def method_missing(m, *args)
      method_name = m
      package_name = args[0]
      arguments = args[1..args.length]
      package = Packages.lookup(package_name)
      guards = guards_for(package_name, method_name)
      before_hooks = before_hooks_for(package_name, method_name)
      after_hooks = after_hooks_for(package_name, method_name)
      if all(guards.map {|g| g.call(package)}, lambda {|x| x})
        before_hooks.each {|hook| hook.call(package)}
        package.send method_name, *arguments
        after_hooks.each {|hook| hook.call(package)}
      end
    end
  end
end

class Package
  include ClassLevelInheritableAttributes
  inheritable_attributes :dependency_names, :home, :support, :downloads, :name
  @home = ENV['AUTO_INSTALLER_HOME']
  @support = "#@home/support"
  @downloads = "#@home/downloads"

  class << self
    def name(*args)
      if args.count == 1
        @name = args[0]
        return Packages.register(@name, self)
      else
        @name
      end
    end

    def depends_on(*dependency_names)
      @dependency_names ||= []
      dependency_names.each {|a| @dependency_names << a}
    end

    def process_support_files
      debug "processesing #@support/#{@name.to_s}/*"
      Dir.glob("#@support/#{@name.to_s}/*").each do |file|
        if File.file? file and /(\.*)(.erb$)/ =~ file
          fname = file.scan(/(.*)(.erb$)/)[0][0]
          File.open(fname, "w") do |f|
            f.write(ERB.new(File.read(file)).result)
          end
        end
      end
    end

    def to_s
      "Package #@name"
    end

    def to_str
      to_s
    end

    def inspect 
      "Package #@name"
    end
  end
end  

class AptitudePackage
  attr_accessor :name

  def initialize(name, aptitude_name)
    @name = name
    @aptitude_name = aptitude_name
  end

  def self.dependency_names
    []
  end

  def install
    shell_out_verbose("aptitude -y install #@aptitude_name")
  end

  def remove
    system("aptitude -y remove #@aptitude_name")
  end

  def installed? 
    debug "checking if #@name is installed"
    search_results = `aptitude search #@aptitude_name`
    installed = search_results.reject {|r| not r =~ /^i/ or not r =~ / #@aptitude_name /}
    not installed.empty?
  end
end

class GemPackage
  attr_accessor :name

  def initialize(name, gem_name)
    @name = name
    @gem_name = gem_name
  end

  def self.dependency_names 
    []
  end

  def install
    shell_out("gem install #@gem_name")
  end
  
  def remove 
    system("gem uninstall #@gem_name")
  end
  
  def installed?
    shell_out("ruby -e \"require '#@gem_name'\"")
  end
end

def aptitude_packages(hash)
  names = hash.keys
  for name in names
    p = AptitudePackage.new(name, hash[name])
    Packages.register(p.name, p)
  end
end

def aptitude_package(name, aptitude_name)
  p = AptitudePackage.new(name, aptitude_name)
  Packages.register(p.name, p)
  return p
end

def gem_package(name, gem_name)
  p = GemPackage.new(name, gem_name)
  Packages.register(p.name, p)
  return p
end

