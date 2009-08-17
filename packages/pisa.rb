require 'httpclient'
require 'fileutils'
include FileUtils

class Pisa < Package
  name :pisa
  depends_on :python

  @@pisa_url = "http://pypi.python.org/packages/source/p/pisa/pisa-3.0.32.tar.gz#md5=d68f2f76e04b10f73c07ef4df937b243"

  def install
    client = HTTPClient.new
    open("#@downloads/pisa.tar.gz", "wb") do |file|
      file.write(client.get_content(@@pisa_url))
    end
    shell_out("tar xf #@home/downloads/pisa.tar.gz -C #@home")
    shell_out("mv -f #@home/pisa-3.0.32/* #@project_directory")
    shell_out("cd #@project_directory && python setup.py install")
  end  
end

