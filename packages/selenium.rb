require 'package'
require 'packages/general'

package :selenium do
  depends_on :java
  install {
    system("wget http://release.seleniumhq.org/selenium-remote-control/1.0.1/selenium-remote-control-1.0.1-dist.zip")
    system("unzip selenium*")
    system("mkdir /var/selenium")    
    system("mv selenium* /var/selenium")
    system("ln -s /var/selenium/selenium-remote-control-1.0.1 /var/selenium/remote-control")
    system("cp support/start-selenium /usr/bin/")
    system("chmod a+x /usr/bin/start-selenium")
  }
  remove {
    system("rm -rf /var/selenium")
    system("rm /usr/bin/start-selenium")
  }
  installed? {
    File.exists? '/var/selenium' and File.exists? '/usr/bin/start-selenium'
  }
end
