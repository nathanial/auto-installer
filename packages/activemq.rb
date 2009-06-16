require 'package'

package :activemq, {
  :depends => [:java, :svn],
  :install => procedure {
    system("wget http://mirror-fpt-telecom.fpt.net/apache/activemq/apache-activemq/5.2.0/apache-activemq-5.2.0-bin.tar.gz")
    system("tar xf apache-activemq-5.2.0-bin.tar.gz")
    system("mv -v apache-activemq-5.2.0 /opt/apache-activemq-5.2.0")
    system("ln -sv /opt/apache-activemq-5.2.0 /opt/active-mq")
    system("ln -sv /opt/apache-activemq-5.2.0/bin/linux-x86-32 /opt/apache-activemq-5.2.0/bin/linux")
    system("cp -v support/activemq /etc/init.d/")
    system("update-rc.d activemq defaults")
  },
  :remove => procedure {
    raise "not implemented"
  },
  :installed? => procedure {
    File.exists?("/opt/apache-activemq-5.2.0")
  }
}