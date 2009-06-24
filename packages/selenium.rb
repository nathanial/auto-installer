require 'package'
require 'packages/general'
require 'rubygems'
require 'httpclient'
require 'parseconfig'
require 'fileutils'
include FileUtils

package(:selenium) {
  depends_on :java
  selenium_url = "http://release.seleniumhq.org/selenium-remote-control/1.0.1/selenium-remote-control-1.0.1-dist.zip"

  install {
    client = HTTPClient.new
    open("selenium-remote-control.zip", "wb") do |file|
      file.write(client.get_content(selenium_url))
    end
    shell_out("unzip selenium-remote-control.zip -d selenium")
    mv 'selenium', '/var/selenium'
    ln_s '/var/selenium/selenium-remote-control-1.0.1', '/var/selenium/remote-control'
    cp 'support/start-selenium', '/usr/bin/'
    chmod 0005, '/usr/bin/start-selenium'
  }

  remove {
    rm_rf '/var/selenium'
    rm_f '/usr/bin/start-selenium'
  }

  installed? {
    File.exists? '/var/selenium' and File.exists? '/usr/bin/start-selenium'
  }
}
