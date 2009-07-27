require 'fileutils'
include FileUtils
include Logging

class ToolServer < Package
  name :toolserver
  depends_on :python, :git, :python_serial

  def install 
    shell_out("git clone git@github.com:teledrill/tdtoold.git #@project_directory")
    shell_out("cd #@project_directory && python setup.py install")
    cp "#@project_directory/init.d/tdtoold", "/etc/init.d/"
    chmod 0755, "/etc/init.d/tdtoold"
    shell_out("update-rc.d tdtoold defaults")
    shell_out("service tdtoold start")
  end
  
  def remove 
    shell_out_force("service tdtoold stop")
    shell_out_force("update-rc.d -f tdtoold remove")
  end
end

