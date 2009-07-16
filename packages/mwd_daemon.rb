require 'fileutils'
require 'logging'
require 'package'
include FileUtils
include Logging

class MWDDaemon < Package
  depends_on :python, :git, :tdsurface

  def install 
    mkdir_p "/var/djang-projects/"
    shell_out("git clone git@github.com:teledrill/mwd-daemon.git /var/django-projects/mwd-daemon")
    ln_s "/var/django-projects/tdsurface", "/var/django-projects/mwd-daemon"
    cp "#@support/mwd_daemon/mwd-daemon", "/etc/init.d/"
    chmod 0755, "/etc/init.d/mwd-daemon"
    shell_out("update-rc.d mwd-daemon defaults")
    shell_out("service mwd-daemon start")
  end

  def remove 
    shell_out_force("service mwd-daemon stop")
    shell_out_force("update-rc.d -f mwd-daemon remove")
    rm_rf "/var/django-projects/mwd-daemon"
  end

  def installed?
    File.exists? "/var/django-projects/mwd-daemon"
  end

  def reinstall
    remove 
    install
  end
end
Packages.register(:mwd_daemon, MWDDaemon.new(:mwd_daemon))
