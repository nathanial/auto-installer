require 'fileutils'
require 'logging'
require 'package'
include FileUtils
include Logging

class MWDDaemon < Package
  depends_on :python, :git, :tdsurface

  @@root_directory = SETTINGS[:package][:directory]
  @@project_directory = "#@@root_directory/mwd-daemon"

  def install(branch='master')
    mkdir_p @@root_directory
    download_mwd_daemon_project
    ln_s "#@@root_directory/tdsurface", @@project_directory
    cp "#@support/mwd_daemon/mwd-daemon", "/etc/init.d/"
    chmod 0755, "/etc/init.d/mwd-daemon"
    shell_out("update-rc.d mwd-daemon defaults")
    shell_out("service mwd-daemon start")
  end

  def remove 
    shell_out_force("service mwd-daemon stop")
    shell_out_force("update-rc.d -f mwd-daemon remove")
    rm_rf @@project_directory
  end

  def installed?
    File.exists? @@project_directory
  end

  def reinstall
    remove 
    install
  end

  def download_mwd_daemon_project(branch)
    info "downloading mwd-daemon source from github"
    shell_out("git clone git@github.com:teledrill/mwd-daemon.git #@@project_directory")
    unless branch == 'master'
      shell_out("cd #@@project_directory && git checkout -b #{branch}")
      shell_out("cd #@@root_directory/tdsurface && git pull origin #{branch}")
    end
  end
end
Packages.register(:mwd_daemon, MWDDaemon.new(:mwd_daemon))
