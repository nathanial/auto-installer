require 'fileutils'
require 'logging'
require 'package'
include FileUtils
include Logging

class PyWITS < Package
  name :pywits
  depends_on :python, :git

  def install 
    mkdir_p @root_directory
    shell_out("git clone git@github.com:erdosmiller/PyWITS.git #@project_directory")
  end

  def remove 
    rm_rf @project_directory
  end

  def installed?
    File.exists? @project_directory
  end
end
    
