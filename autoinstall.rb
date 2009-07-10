#!/usr/bin/env ruby
$LOAD_PATH << ENV['AUTO_INSTALLER_HOME']
require 'package'

Dir.glob("#{ENV['AUTO_INSTALLER_HOME']}/packages/*").each do |p|
  if p =~ /[.]rb$/
    eval("require '#{p}'")
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
