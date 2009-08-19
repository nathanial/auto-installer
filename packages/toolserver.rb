require 'fileutils'
include FileUtils
include Logging

class ToolServer < Package
  name :toolserver
  depends_on :python, :git, :python_serial
  repository :git, "git@github.com:teledrill/tdtoold.git"
  installs_service :script => "#@project_directory/init.d/tdtoold"

  def install 
    shell_out("cd #@project_directory && python setup.py install --install-scripts=/usr/local/bin")
    touch "/var/log/tdtoold.log"
    shell_out("chmod a+rw /var/log/tdtoold.log")
  end
end

