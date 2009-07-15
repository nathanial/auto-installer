require 'fileutils'
include FileUtils
include Logging

class ToolServer < Package
  depends_on :python, :git, :python_serial

  def install 
    mkdir_p "/var/django-projects/"
    shell_out("git clone git@github.com:teledrill/tdtoold.git /var/django-projects/tdtoold")
    shell_out("cd /var/django-projects/tdtoold && python setup.py install")
    cp "/var/django-projects/tdtoold/init.d/tdtoold", "/etc/init.d/"
    shell_out("update-rc.d tdtoold defaults")
    shell_out("service tdtoold start")
  end
  
  def remove 
    shell_out_force("service tdtoold stop")
    shell_out_force("update-rc.d -f tdtoold remove")
    rm_rf "/var/django-projects/tdtoold"
  end

  def installed?
    File.exists? "/var/django-projects/tdtoold"
  end
end
Packages.register(:toolserver, ToolServer.new(:toolserver))
