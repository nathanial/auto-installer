require 'rubygems'
require 'httpclient'
require 'fileutils'
include FileUtils
include Logging

class Selenium < Package
  name :selenium
  depends_on :java
  @@selenium_url = "http://release.seleniumhq.org/selenium-remote-control/1.0.1/selenium-remote-control-1.0.1-dist.zip"

  def install 
    download_selenium_remote_control
    create_selenium_directories
    install_selenium_service
  end

  def remove
    shell_out_force("service selenium stop")
    shell_out_force("update-rc.d -f selenium remove")
    rm_rf "/opt/selenium"
    rm_f '/etc/init.d/selenium'
    rm_rf "#{Package.downloads}/selenium"
  end

  def installed?
    File.exists? '/opt/selenium' 
  end

  def download_selenium_remote_control
    info "downloading selenium-remote-control.zip from #{@@selenium_url}"
    client = HTTPClient.new
    open("#{Package.downloads}/selenium-remote-control.zip", "wb") do |file|
      file.write(client.get_content(@@selenium_url))
    end
    shell_out("unzip #{Package.downloads}/selenium-remote-control.zip -d #{Package.downloads}/selenium")
  end    

  def create_selenium_directories
    info "creating selenium directories"
    mkdir "/opt/selenium"
    mkdir "/opt/selenium/profile"
  end

  def install_selenium_service
    info "installing selenium service"
    mv "#{Package.downloads}/selenium/selenium-remote-control-1.0.1/selenium-server-1.0.1/selenium-server.jar", '/opt/selenium'
    cp "#{Package.support}/selenium/selenium", "/etc/init.d/"    
    shell_out("update-rc.d selenium defaults")
    chmod 0005, '/etc/init.d/selenium'
    shell_out("service selenium start")
  end    
    
end
