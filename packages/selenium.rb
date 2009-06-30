require 'package'
require 'packages/general'
require 'rubygems'
require 'httpclient'
require 'fileutils'
include FileUtils

package(:selenium) {
  depends_on :java
  selenium_url = "http://release.seleniumhq.org/selenium-remote-control/1.0.1/selenium-remote-control-1.0.1-dist.zip"

  @template_properties[:xauthority] = "/home/nathan/.Xauthority"
  @template_properties[:home] = "home/nathan"

  install {
    process_support_files
    client = HTTPClient.new
    open("#@downloads/selenium-remote-control.zip", "wb") do |file|
      file.write(client.get_content(selenium_url))
    end
    shell_out("unzip #@downloads/selenium-remote-control.zip -d #@downloads/selenium")

    mkdir "/opt/selenium"
    mkdir "/opt/selenium/profile"

    mv "#@downloads/selenium/selenium-remote-control-1.0.1/selenium-server-1.0.1/selenium-server.jar", '/opt/selenium'
    cp "#@support/selenium/selenium", "/etc/init.d/"
    
    shell_out("update-rc.d selenium defaults")
    chmod 0005, '/etc/init.d/selenium'
    shell_out("service selenium start")
  }

  remove {
    system("service selenium stop")
    system("update-rc.d -f selenium remove")
    rm_rf "/opt/selenium"
    rm_f '/etc/init.d/selenium'
    rm_rf "#@downloads/selenium"
  }

  installed? {
    File.exists? '/opt/selenium' 
  }
}
