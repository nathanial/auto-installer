require 'rubygems'
require 'httpclient'
require 'fileutils'
include FileUtils

class Hudson < Package
  name :hudson
  depends_on :java, :selenium
  directories "#@project_directory/plugins"
  installs_service

  @@hudson_war_url = "http://hudson-ci.org/latest/hudson.war"
  @@hudson_cli_url = "http://localhost:8080/jnlpJars/hudson-cli.jar"
  @@git_plugin_url = "https://hudson.dev.java.net/files/documents/2402/119838/git.hpi"
  @@client = HTTPClient.new

  def install 
    install_hudson_war
    install_git_plugin
    sleep(10)
  end

  def install_hudson_war 
    open("#@downloads/hudson.war", "wb") do |file|
      file.write(@@client.get_content(@@hudson_war_url))
    end
    mv "#@downloads/hudson.war", @project_directory
  end
  
  def install_git_plugin
    open("#@downloads/git.hpi", "wb") do |file|
      file.write(@@client.get_content(@@git_plugin_url))
    end
    cp "#@downloads/git.hpi", "#@project_directory/plugins"
  end

end
