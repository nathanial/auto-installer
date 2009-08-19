require 'fileutils'
require 'logging'
require 'package'
include FileUtils
include Logging

class MWDDaemon < Package
  name :mwd_daemon
  depends_on :python, :git, :tdsurface
  repository :git, "git@github.com:teledrill/mwd-daemon.git"
  installs_service

  def install
    ln_s TDSurface.project_directory, @project_directory
  end
end

