require 'rubygems'
require 'httpclient'
require 'fileutils'
include FileUtils
include Logging

class Selenium < Package
  name :selenium
  depends_on :java
  installs_service
  @@selenium_url = "http://release.seleniumhq.org/selenium-remote-control/1.0.1/selenium-remote-control-1.0.1-dist.zip"

  def install 
    download_selenium_remote_control
    mv "#@downloads/selenium/selenium-remote-control-1.0.1/selenium-server-1.0.1/selenium-server.jar", @project_directory
  end

  def download_selenium_remote_control
    info "downloading selenium-remote-control.zip from #@@selenium_url"
    client = HTTPClient.new
    open("#@downloads/selenium-remote-control.zip", "wb") do |file|
      file.write(client.get_content(@@selenium_url))
    end
    shell_out("unzip #@downloads/selenium-remote-control.zip -d #@downloads/selenium")
  end    
end
