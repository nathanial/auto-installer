require 'httpclient'
require 'fileutils'
include FileUtils

class Cheetah < Package
  name :cheetah
  depends_on :python

  @@tarball_url = "http://softlayer.dl.sourceforge.net/project/cheetahtemplate/Cheetah/v2.2.1/Cheetah-2.2.1.tar.gz"
  @@client = HTTPClient.new
  
  def install
    puts "here"
    open("#@downloads/Cheetah-2.2.1.tar.gz", "wb") do |file|
      file.write(@@client.get_content(@@tarball_url))
    end
    puts "there"
    shell_out("tar xf #@home/downloads/Cheetah-2.2.1.tar.gz -C #@home")
    puts "that"
    shell_out("mv -f #@home/Cheetah-2.2.1/* #@project_directory")
    shell_out("cd #@project_directory && python setup.py install")
  end
  
end
