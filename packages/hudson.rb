require 'package'
require 'packages/general'
require 'packages/selenium'
require 'rubygems'
require 'httpclient'
require 'fileutils'
include FileUtils

package(:hudson) {
  depends_on :java, :selenium
  hudson_war_url = "http://hudson-ci.org/latest/hudson.war"
  hudson_cli_url = "http://localhost:8080/jnlpJars/hudson-cli.jar"
  git_plugin_url = "https://hudson.dev.java.net/files/documents/2402/119838/git.hpi"

  client = HTTPClient.new

  install {
    install_hudson_war
    install_git_plugin
    install_hudson_service
    sleep(10)
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

  define(:install_hudson_war){
    download_hudson_war
    mkdir '/opt/hudson'
    mv "#@downloads/hudson.war", '/opt/hudson/'
  }
  
  define(:install_hudson_service){
    cp "#@support/hudson/run-hudson", '/opt/hudson/'
    cp "#@support/hudson/hudson", '/etc/init.d/'
    shell_out('update-rc.d hudson defaults')
    chmod 0005, '/opt/hudson/run-hudson'
    chmod 0005, '/etc/init.d/hudson'
    shell_out("service hudson start")
  }

  define(:install_git_plugin){
    download_git_plugin
    mkdir_p '/opt/hudson/plugins/'
    cp "#@downloads/git.hpi", '/opt/hudson/plugins/'
  }

  define(:download_hudson_war) {
    open("#@downloads/hudson.war", "wb") do |file|
      file.write(client.get_content(hudson_war_url))
    end
  }

  define(:download_hudson_cli) {
    open("#@downloads/hudson-cli.jar", "wb") do |file|
      file.write(client.get_content(hudson_cli_url))
    end
  }

  define(:download_git_plugin){
    open("#@downloads/git.hpi", "wb") do |file|
      file.write(client.get_content(git_plugin_url))
    end
  }
}
