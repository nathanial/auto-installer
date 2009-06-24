require 'package'
require 'packages/general'

package(:hudson) {
  depends_on :java
  install {
    shell_out("""
    wget http://hudson-ci.org/latest/hudson.war
    mkdir -v /opt/hudson
    mv -v hudson.war /opt/hudson/
    cp -v support/run-hudson /opt/hudson/
    cp -v support/hudson /etc/init.d/
    update-rc.d hudson defaults
    chmod a+rx /etc/init.d/hudson
    chmod a+rx /opt/hudson/run-hudson
    """)
  }
  remove {
    shell_out("""
    update-rc.d -f hudson remove
    rm -rfv /opt/hudson/
    rm -v /etc/init.d/hudson
    """)
  }
  installed? {
    File.exists? "/opt/hudson/hudson.war"
  }
}
