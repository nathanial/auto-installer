#!/usr/bin/env ruby
$LOAD_PATH << ENV['AUTO_INSTALLER_HOME']
require 'package'
require 'rubygems'
require 'aquarium'

Dir.glob("#{ENV['AUTO_INSTALLER_HOME']}/packages/*").each do |p|
  if p =~ /[.]rb$/
    puts "loading #{p}"
    eval("require '#{p}'")
  end
end

all_packages = Aquarium::Utils::TypeUtils.descendents Package

aspect1 = Aspect.new :around, :method => :install, :on_type_and_descendents => Package do |point, obj, *args|
  if not obj.installed?
    puts "dependencies = #{obj.dependencies}"
    obj.dependencies.each {|d| d.install}
    puts "installing #{obj.name}"
    point.proceed
  end
end

aspect2 = Aspect.new :around, :method => :remove, :on_type_and_descendents => Package do |point, obj, *args|
  if obj.installed?
    puts "removing #{obj.name}"
    point.proceed
  end
end

target = ARGV[0]
command = ARGV[1]
arguments = ARGV[2..ARGV.length].join(',')

text = nil
if arguments.length > 0
  text =  """
p = Packages.#{command}(:#{target}, *#{arguments})
"""
else
  text = """
p = Packages.#{command}(:#{target})
"""
end
puts eval text
