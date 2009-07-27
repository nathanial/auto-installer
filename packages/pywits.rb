require 'fileutils'
require 'logging'
require 'package'
include FileUtils
include Logging

class PyWITS < Package
  name :pywits
  depends_on :python, :git

  def install 
    shell_out("git clone git@github.com:erdosmiller/PyWITS.git #@project_directory")
  end
end
    
