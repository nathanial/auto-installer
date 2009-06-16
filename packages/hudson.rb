require 'package'

package :hudson, {
  :depends => [:java],
  :install => procedure {
    system("wget https://hudson.dev.java.net/files/documents/2402/136743/hudson.war")
    system("mkdir -v /opt/hudson")
    system("mv -v hudson.war /opt/hudson/")
    system("cp -v support/run-hudson /opt/hudson/")
    system("cp -v support/hudson /etc/init.d/")
    system("update-rc.d hudson defaults")
  },
  :remove => procedure {
    system("update-rc.d hudson remove")
    system("rm -rfv /opt/hudson/")
    system("rm -v /etc/init.d/hudson")
    system("rm -v /etc/init.d/run-hudson")
  },
  :installed? => procedure {
    File.exists? "/opt/hudson/hudson.war"
  }
}
