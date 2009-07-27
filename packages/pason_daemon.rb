require 'fileutils'
require 'logging'
require 'package'
include FileUtils
include Logging

class PasonDaemon < Package 
  name :pason_daemon
  depends_on :python, :git, :tdsurface, :pywits

  def install
    shell_out("git clone git@github.com:teledrill/pason-daemon.git #@project_directory")
    ln_s "#@project_directory/PyWITS/", "#@project_directory"
    ln_s "#@root_directory/tdsurface", "#@project_directory"
    cp "#@support/pason_daemon/pason", "/etc/init.d/"
    chmod 0755, "/etc/init.d/pason"
    shell_out("update-rc.d pason defaults")
    shell_out("service pason start")
  end

  def remove
    shell_out_force("service pason stop")
    shell_out_force("update-rc.d -f pason remove")
  end
end
