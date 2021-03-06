#!/usr/bin/env ruby
$LOAD_PATH << ENV['AUTO_INSTALLER_HOME']
require 'package'
require 'rubygems'
require 'aquarium'
require 'fileutils'
require 'logging'
require 'options'
include FileUtils
include Logging

Logging.logger.level = Logger::DEBUG

Dir.glob("#{ENV['AUTO_INSTALLER_HOME']}/downloads/*").each do |p|
  rm_rf p
end

Dir.glob("#{ENV['AUTO_INSTALLER_HOME']}/packages/*").each do |p|
  if p =~ /[.]rb$/
    debug "loading #{p}"
    eval("require '#{p}'")
  end
end

require 'hooks'

ProgramOptions::handle_options(ARGV)

def stringify(args)
  args.map {|a| "\"#{a}\""}
end


command = ARGV[0]
target = ARGV.last
arguments = stringify(ARGV[1..ARGV.length-2]).join(',')
begin 
  text = nil
  if arguments.length > 0
    text =  """
p = Packages.#{command}(:#{target}, #{arguments})
"""
  else
    text = """
p = Packages.#{command}(:#{target})
"""
  end
  puts "text = #{text}"
  result = eval text
  puts result unless result.nil?
rescue Exception => e
  error e
  exit 1
end
