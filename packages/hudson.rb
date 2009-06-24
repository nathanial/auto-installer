require 'package'
require 'packages/general'
require 'rubygems'
require 'httpclient'
require 'fileutils'
include FileUtils

package(:hudson) {
  depends_on :java

  install {
    client = HTTPClient.new
    open("#@downloads/hudson.war", "wb") do |file|
      file.write(client.get_content("http://hudson-ci.org/latest/hudson.war"))
    end
    mkdir '/opt/hudson'
    mv "#@downloads/hudson.war", '/opt/hudson/'
    cp "#@support/run-hudson", '/opt/hudson/'
    cp "#@support/hudson", '/etc/init.d/'
    shell_out('update-rc.d hudson defaults')
    chmod 0005, '/opt/hudson/run-hudson'
    chmod 0005, '/etc/init.d/hudson'
    shell_out("service hudson start")
  }

  remove {
    system("service hudson stop")
    system("update-rc.d -f hudson remove")
    rm_rf '/opt/hudson/'
    rm_f '/etc/init.d/hudson'
  }

  installed? {
    File.exists? "/opt/hudson/" 
  }
}
