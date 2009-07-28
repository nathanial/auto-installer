require 'fileutils'
require 'logging'
require 'package'
include FileUtils
include Logging

class PyWITS < Package
  name :pywits
  depends_on :python, :git
  repository :git, "git@github.com:erdosmiller/PyWITS.git"
end
    
