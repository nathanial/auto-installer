require 'fileutils'
require 'logging'
require 'package'
include FileUtils
include Logging

class MWDDaemon < Package
  name :mwd_daemon
  depends_on :python, :git, :tdsurface
  repository :git, "git@github.com:teledrill/mwd-daemon.git"

  def install
    ln_s TDSurface.project_directory, @project_directory
    cp "#@support/mwd_daemon/mwd-daemon", "/etc/init.d/"
    chmod 0755, "/etc/init.d/mwd-daemon"
    shell_out("update-rc.d mwd-daemon defaults")
    shell_out("service mwd-daemon start")
  end

  def remove 
    shell_out_force("service mwd-daemon stop")
    shell_out_force("update-rc.d -f mwd-daemon remove")
  end

end

