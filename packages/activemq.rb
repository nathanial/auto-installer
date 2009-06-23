require 'package'
require 'packages/general'

package(:activemq) {
  depends_on :java, :svn

  install {
    system("wget http://mirror-fpt-telecom.fpt.net/apache/activemq/apache-activemq/5.2.0/apache-activemq-5.2.0-bin.tar.gz")
    system("tar xf apache-activemq-5.2.0-bin.tar.gz")
    system("mv -v apache-activemq-5.2.0 /opt/apache-activemq-5.2.0")
    system("ln -sv /opt/apache-activemq-5.2.0 /opt/active-mq")
    system("ln -sv /opt/apache-activemq-5.2.0/bin/linux-x86-32 /opt/apache-activemq-5.2.0/bin/linux")
    system("cp -v support/activemq /etc/init.d/")
    system("chmod a+x /etc/init.d/activemq")
    system("update-rc.d activemq defaults")
  }
  
  remove {
    system("rm -rf /opt/active-mq")
    system("rm -rf /opt/apache-activemq-5.2.0")
    system("update-rc.d -f activemq remove")
    systme("rm /etc/init.d/activemq")
  }

  installed? {
    File.exists?("/opt/apache-activemq-5.2.0")
  }
}
