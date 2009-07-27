require 'fileutils'
require 'logging'
require 'package'
include FileUtils
include Logging

class PyWITS < Package
  depends_on :python, :git

  @@root_directory = SETTINGS[:package][:directory]
  @@project_directory = "#@@root_directory/PyWITS"

  def install 
    mkdir_p @@root_directory
    shell_out("git clone git@github.com:erdosmiller/PyWITS.git #@@project_directory")
  end

  def remove 
    rm_rf @@project_directory
  end

  def installed?
    File.exists? @@project_directory
  end

  def reinstall
    remove 
    install
  end
end
Packages.register(:pywits, PyWITS.new(:pywits))
    
