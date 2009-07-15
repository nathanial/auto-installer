require 'fileutils'
require 'logging'
require 'package'
include FileUtils
include Logging

class PyWITS < Package
  depends_on :python, :git

  def install 
    mkdir_p "/var/django-projects/"
    shell_out("git clone git@github.com:erdosmiller/PyWITS.git /var/django-projects/PyWITS")
  end

  def remove 
    rm_rf "/var/django-projects/PyWITS"
  end

  def installed?
    File.exists? "/var/django-projects/PyWITS"
  end

  def reinstall
    remove 
    install
  end
end
Packages.register(:pywits, PyWITS.new(:pywits))
    
