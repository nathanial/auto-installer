require 'package'
require 'packages/general'

package(:hudson) {
  depends_on :java
  install {
    system("wget http://hudson-ci.org/latest/hudson.war")
    system("mkdir -v /opt/hudson")
    system("mv -v hudson.war /opt/hudson/")
    system("cp -v support/run-hudson /opt/hudson/")
    system("cp -v support/hudson /etc/init.d/")
    system("update-rc.d hudson defaults")
    system("chmod a+rw /opt/hudson/run-hudson")
    system("chmod a+rw /etc/init.d/hudson")
  }
  remove {
    system("update-rc.d -f hudson remove")
    system("rm -rfv /opt/hudson/")
    system("rm -v /etc/init.d/hudson")
  }
  installed? {
    File.exists? "/opt/hudson/hudson.war"
  }
}
