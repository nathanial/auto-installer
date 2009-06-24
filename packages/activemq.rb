require 'package'
require 'packages/general'
require 'open-uri'
require 'fileutils'
include FileUtils

package(:activemq) {
  depends_on :java, :svn

  install {
    system("wget http://mirror-fpt-telecom.fpt.net/apache/activemq/apache-activemq/5.2.0/apache-activemq-5.2.0-bin.tar.gz")
    shell_out("tar xf apache-activemq-5.2.0-bin.tar.gz")
    mv 'apache-activemq-5.2.0', '/opt/apache-activemq-5.2.0'
    ln_s '/opt/apache-activemq-5.2.0', '/opt/active-mq'
    ln_s '/opt/apache-activemq-5.2.0/bin/linux-x86-32', '/opt/apache-activemq-5.2.0/bin/linux'
    cp 'support/activemq', '/etc/init.d/'
    chmod 0005, '/etc/init.d/activemq'
    shell_out("update-rc.d activemq defaults")
  }
  
  remove {
    rm_rf '/opt/active-mq'
    rm_rf '/opt/apache-activemq-5.2.0'
    shell_out("update-rc.d -f activemq remove")
    rm '/etc/init.d/activemq'
  }

  installed? {
    File.exists?("/opt/apache-activemq-5.2.0")
  }
}
