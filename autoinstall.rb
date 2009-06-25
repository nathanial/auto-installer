#!/usr/bin/env ruby
$LOAD_PATH << ENV['AUTO_INSTALLER_HOME']
require 'package'
require 'packages/general'
require "packages/#{ARGV[1]}"

case ARGV[0]
when "install" then 
  Packages.install(ARGV[1].to_sym)
when "remove" then
  Packages.remove(ARGV[1].to_sym)
else 
  raise "usage: install|remove <item>"
end
