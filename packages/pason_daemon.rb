require 'fileutils'
require 'logging'
require 'package'
include FileUtils
include Logging

class PasonDaemon < Package 
  name :pason_daemon
  depends_on :python, :git, :tdsurface, :pywits

  @@root_directory = SETTINGS[:package][:directory]
  @@project_directory = "#@@root_directory/pason-daemon"

  def install
    mkdir_p @root_directory
    shell_out("git clone git@github.com:teledrill/pason-daemon.git #@@project_directory")
    ln_s "#@@root_directory/PyWITS/PyWITS/", "#@@project_directory"
    ln_s "#@@root_directory/tdsurface", "#@@project_directory"
    cp "#{Package.support}/pason_daemon/pason", "/etc/init.d/"
    chmod 0755, "/etc/init.d/pason"
    shell_out("update-rc.d pason defaults")
    shell_out("service pason start")
  end

  def remove
    shell_out_force("service pason stop")
    shell_out_force("update-rc.d -f pason remove")
    rm_rf "#@@project_directory"
  end
  
  def installed?
    File.exists? "#@@project_directory"
  end

  def reinstall
    remove
    install
  end
end
