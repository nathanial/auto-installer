require 'httpclient'
require 'fileutils'
include FileUtils

class ReportLab < Package
  name :report_lab
  depends_on :python

  @@report_lab_url = "http://www.reportlab.org/ftp/ReportLab_2_3.tar.gz"

  def install
    client = HTTPClient.new
    open("#@downloads/ReportLab.tar.gz", "wb") do |file|
      file.write(client.get_content(@@report_lab_url))
    end
    shell_out("tar xf #@home/downloads/ReportLab.tar.gz -C #@home")
    shell_out("mv -f #@home/ReportLab_2_3/* #@project_directory")
    shell_out("cd #@project_directory && python setup.py install")
  end
  
end

