require 'graph'
require 'erb'
require 'rexml/document'
require 'rubygems'
require 'aquarium'
include Aquarium::Aspects

SETTINGS = {}

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

class Packages
  @@registered_packages = {}

  class << self 
    def register(*args)
      if args.count == 1
        package = args[0]
        @@registered_packages[package.name] = package
      else 
        name = args[0]
        package = args[1]
        puts "registering #{package} as #{name}"
        @@registered_packages[name] = package
      end
    end
    
    def unregister(package)
      @@registered_packages[package.name] = nil
    end
    
    def lookup(name)
      p = @@registered_packages[name]
      if not p
        raise "cannot find package name #{name}"
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
      package.send method_name, *arguments
    end
  end
end

class Package
  attr_accessor :dependency_names, :name

  def initialize
    @dependency_names = []
    @home = ENV['AUTO_INSTALLER_HOME']
    @support = "#@home/support"
    @downloads = "#@home/downloads"
  end

  def install 
    raise "unimplemented"
  end

  def remove 
    raise "unimplemented"
  end

  def installed?
    raise "unimplemented"
  end

  def self.depends_on(*dependency_names)
    Aspect.new :after, :method => :initialize, :type => self,
    :restricting_methods_to => :private_methods do |point, obj, *args|
      puts "in depends_on for #{self} with dependencies = #{dependency_names}" 
      dependency_names.each {|a| obj.add_dependency(a)}
    end
  end

  def add_dependency(dependency)
    @dependency_names << dependency
  end

  def dependencies
    @dependency_names.map {|name| Packages.lookup(name)}
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

class AptitudePackage < Package
  def initialize(name, aptitude_name)
    @name = name
    @aptitude_name = aptitude_name
  end

  def install
    shell_out("aptitude -y install #@aptitude_name")
  end

  def remove
    system("aptitude -y remove #@aptitude_name")
  end

  def installed? 
    puts "checking if #@name is installed"
    search_results = `aptitude search #@aptitude_name`
    installed = search_results.reject {|r| not r =~ /^i/}
    not installed.empty?
  end
end

class GemPackage < Package
  attr_accessor :name, :gem_name

  def initialize(name, gem_name)
    @name = name
    @gem_name = gem_name
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
    Packages.register(p)
  end
end

def aptitude_package(name, aptitude_name)
  p = AptitudePackage.new(name, aptitude_name)
  Packages.register(p)
  return p
end

def gem_package(name, gem_name)
  p = GemPackage.new(name, gem_name)
  Packages.register(p)
  return p
end
