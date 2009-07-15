require 'fileutils'
require 'logging'
require 'package'
include FileUtils
include Logging

class PasonDaemon < Package 
  depends_on :python, :git, :tdsurface, :pywits

  def install
    mkdir_p "/var/django-projects/"
    shell_out("git clone git@github.com:teledrill/pason-daemon.git /var/django-projects/pason-daemon")
    ln_s "/var/django-projects/PyWITS/PyWITS/", "/var/django-projects/pason-daemon/"
    ln_s "/var/django-projects/tdsurface", "/var/django-projects/pason-daemon/"
    cp "#@support/pason_daemon/pason", "/etc/init.d/"
    shell_out("update-rc.d pason defaults")
    chmod 0005, "/etc/init.d/pason"
    shell_out("service pason start")
  end

  def remove
    shell_out_force("service pason stop")
    shell_out_force("update-rc.d -f pason remove")
    rm_rf "/var/django-projects/pason-daemon"
  end
  
  def installed?
    File.exists? "/var/django-projects/pason-daemon"
  end

  def reinstall
    remove
    install
  end
end
Packages.register(:pason_daemon, PasonDaemon.new(:pason_daemon))
