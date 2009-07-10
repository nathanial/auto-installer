require 'package'
require 'packages/general'
require 'open-uri'
require 'rubygems'
require 'httpclient'
require 'fileutils'
include FileUtils

package(:activemq) do
  depends_on :java, :svn
  @@apache_activemq_url = "http://mirror-fpt-telecom.fpt.net/apache/activemq/apache-activemq/5.2.0/apache-activemq-5.2.0-bin.tar.gz"

  def install
    client = HTTPClient.new
    open("#@home/downloads/activemq.tar.gz", "wb") do |file|
      file.write(client.get_content(@@apache_activemq_url))
    end
    shell_out("tar xf #@home/downloads/activemq.tar.gz -C #@home")
    mv "#@home/apache-activemq-5.2.0", '/opt/apache-activemq-5.2.0'
    ln_s '/opt/apache-activemq-5.2.0', '/opt/active-mq'
    ln_s '/opt/apache-activemq-5.2.0/bin/linux-x86-32', '/opt/apache-activemq-5.2.0/bin/linux'
    cp "#@support/activemq/activemq", '/etc/init.d/'
    chmod 0005, '/etc/init.d/activemq'
    shell_out("update-rc.d activemq defaults")
    
    wrapper_conf_path = "/opt/active-mq/bin/linux/wrapper.conf"
    wrapper_conf = File.open(wrapper_conf_path).read
    wrapper_conf.gsub!(/set\.default\.ACTIVEMQ_HOME=.*$/, 'set.default.ACTIVEMQ_HOME=/opt/active-mq')
    wrapper_conf.gsub!(/set\.default\.ACTIVEMQ_BASE=.*$/, 'set.default.ACTIVEMQ_BASE=/opt/active-mq')
    open(wrapper_conf_path, "w") {|f| f.print(wrapper_conf)}    
  end
  
  def remove
    rm_rf '/opt/active-mq'
    rm_rf '/opt/apache-activemq-5.2.0'
    shell_out("update-rc.d -f activemq remove")
    rm '/etc/init.d/activemq'
  end

  def installed? 
    File.exists?("/opt/apache-activemq-5.2.0")
  end
end
