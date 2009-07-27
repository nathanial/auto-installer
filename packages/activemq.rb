require 'open-uri'
require 'rubygems'
require 'httpclient'
require 'fileutils'
include FileUtils

class ActiveMQ < Package
  name :activemq
  depends_on :java

  @@apache_activemq_url = "http://mirror-fpt-telecom.fpt.net/apache/activemq/apache-activemq/5.2.0/apache-activemq-5.2.0-bin.tar.gz"

  def install
    client = HTTPClient.new
    open("#@downloads/activemq.tar.gz", "wb") do |file|
      file.write(client.get_content(@@apache_activemq_url))
    end
    shell_out("tar xf #@home/downloads/activemq.tar.gz -C #@home")
    mv_rf "#@home/apache-activemq-5.2.0/*", @project_directory
    ln_s "#@project_directory/bin/linux-x86-32", "#@project_directory/bin/linux"
    cp "#@support/activemq/activemq", '/etc/init.d/'
    chmod 0005, '/etc/init.d/activemq'
    shell_out("update-rc.d activemq defaults")
    
    wrapper_conf_path = "#@project_directory/bin/linux/wrapper.conf"
    wrapper_conf = File.open(wrapper_conf_path).read
    wrapper_conf.gsub!(/set\.default\.ACTIVEMQ_HOME=.*$/, 'set.default.ACTIVEMQ_HOME=#@project_directory')
    wrapper_conf.gsub!(/set\.default\.ACTIVEMQ_BASE=.*$/, 'set.default.ACTIVEMQ_BASE=#@project_directory')
    open(wrapper_conf_path, "w") {|f| f.print(wrapper_conf)}    
  end
  
  def remove
    shell_out("update-rc.d -f activemq remove")
    rm '/etc/init.d/activemq'
  end

  def installed? 
    File.exists? @project_directory
  end
end

