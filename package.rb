require 'graph'
require 'erb'
require 'rexml/document'
require 'rubygems'
require 'aquarium'
require 'logging'
require 'fileutils'
include FileUtils
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
      debug "registering #{package} as #{name}"
      @@registered_packages[name] = package
    end
    
    def unregister(package)
      @@registered_packages[package.name] = nil
    end
    
    def lookup(name)
      package = @@registered_packages[name]
      if not package
        raise PackageNotFound.new("cannot find package name \"#{name}\"")
      end
      if package.instance_of? Class 
        package = package.new
        @@registered_packages[name] = package
      end
      return package
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
        debug "installing #{package_name}" if method_name == :install
        before_hooks.each {|hook| hook.call(package)}
        package.send method_name, *arguments
        after_hooks.each {|hook| hook.call(package)}
      end
    end
  end
end

class Package
  include ClassLevelInheritableAttributes
  inheritable_attributes :dependency_names, :home, :support, :downloads, :name, :root_directory, :project_directory, :directories, :does_install_service, :install_script, :does_have_repository, :repository_type, :repository_url
  @root_directory = SETTINGS[:package][:directory]
  @home = ENV['AUTO_INSTALLER_HOME']
  @support = "#@home/support"
  @downloads = "#@home/downloads"

  attr_accessor :name

  def initialize
    @name = self.class.name
    @root_directory = self.class.root_directory
    @project_directory = self.class.project_directory
    @home = self.class.home
    @support = self.class.support
    @downloads = self.class.downloads
    @directories = self.class.directories
    @does_install_service = self.class.does_install_service
    @install_script = self.class.install_script
    @does_have_repository = self.class.does_have_repository
    @repository_type = self.class.repository_type
    @repository_url = self.class.repository_url
  end


  def remove
  end
  
  def install
  end

  def installed?
    File.exists? @project_directory
  end

  def reinstall
    Packages.remove(@name)
    Packages.install(@name)
  end

  def get_binding
    binding
  end

  def has_repository?
    @does_have_repository
  end

  def download_repository
    debug "downloading repository for #@name at #@repository_url"
    if @repository_type == :git
      shell_out("git clone #@repository_url #@project_directory")
    elsif @repository_type == :svn
      shell_out("svn checkout #@repository_url #@project_directory")
    else
      raise "unknown repository type #@repository_type for #@name" 
    end
  end

  def installs_service? 
    @does_install_service
  end

  def install_service
    debug "installing service for #@name"
    script_name = (@install_script.split /\//).last
    cp @install_script, "/etc/init.d/"
    shell_out("update-rc.d #{script_name} defaults")
    shell_out("service #{script_name} start")
  end

  def remove_service
    debug "removing service for #@name"
    script_name (@install_script.split /\//).last
    shell_out("service #{script_name} stop")
    shell_out("update-rc.d -f #{script_name} remove")
    rm_f "/etc/init.d/#{script_name}"
  end

  def create_directories
    debug "creating directories for #@name"
    mkdir_p @root_directory
    mkdir_p @project_directory
    for directory in @directories
      mkdir_p directory
    end
  end

  def remove_directories
    debug "removing #@project_directory"
    rm_rf @project_directory
    for directory in @directories
      debug "remove #{directory}"
      rm_rf directory
    end
  end

  def process_support_files
    debug "processesing #@support/#{@name.to_s}/*"
    Dir.glob("#@support/#{@name.to_s}/*").each do |file|
      if File.file? file and /(\.*)(.erb$)/ =~ file
        fname = file.scan(/(.*)(.erb$)/)[0][0]
        File.open(fname, "w") do |f|
          f.write(ERB.new(File.read(file)).result(get_binding))
        end
      end
    end
  end

  class << self
    def name(*args)
      if args.count == 1
        @name = args[0]
        @project_directory = "#@root_directory/#@name"
        return Packages.register(@name, self)
      else
        @name
      end
    end
    
    def depends_on(*dependency_names)
      @dependency_names ||= []
      dependency_names.each {|a| @dependency_names << a}
    end

    def directories(*directories)
      @directories ||= []
      directories.each {|a| @directories << a}
    end

    def repository(type, url)
      debug "#@name has repository type #{type} at #{url}"
      @repository_type = type
      @repository_url = url
      @does_have_repository = true
    end

    def installs_service(options = {})
      @install_script = options[:script] || "#@support/#@name/#@name"
      debug "#@name installs service using #@install_script"
      @installs_service = true
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

