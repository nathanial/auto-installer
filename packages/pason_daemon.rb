require 'fileutils'
require 'logging'
require 'package'
include FileUtils
include Logging

class PasonDaemon < Package 
  name :pason_daemon
  depends_on :python, :git, :tdsurface, :pywits
  repository :git, "git@github.com:teledrill/pason-daemon.git"
  installs_service

  def install
    ln_s "#{PyWITS.project_directory}/PyWITS", "#@project_directory"
    ln_s "#{TDSurface.project_directory}", "#@project_directory"
  end
end
