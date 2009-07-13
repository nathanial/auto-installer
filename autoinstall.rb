#!/usr/bin/env ruby
$LOAD_PATH << ENV['AUTO_INSTALLER_HOME']
require 'package'
require 'rubygems'
require 'aquarium'
require 'fileutils'
require 'logging'
include FileUtils
include Logging

Dir.glob("#{ENV['AUTO_INSTALLER_HOME']}/downloads/*").each do |p|
  rm_rf p
end

Dir.glob("#{ENV['AUTO_INSTALLER_HOME']}/packages/*").each do |p|
  if p =~ /[.]rb$/
    debug "loading #{p}"
    eval("require '#{p}'")
  end
end

aspect1 = Aspect.new :around, :method => :install, :on_type_and_descendents => Package do |point, obj, *args|
  if not obj.installed?
    obj.dependencies.each {|d| d.install}
    info "installing #{obj.name}"
    point.proceed
  end
end

aspect2 = Aspect.new :around, :method => :remove, :on_type_and_descendents => Package do |point, obj, *args|
  if obj.installed?
    info "removing #{obj.name}"
    point.proceed
  end
end

target = ARGV[0]
command = ARGV[1]
arguments = ARGV[2..ARGV.length].join(',')
begin 
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
rescue Exception => e
  error e.message
  exit 1
end
