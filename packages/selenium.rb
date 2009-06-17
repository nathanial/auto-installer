require 'package'
require 'packages/general'

package :selenium, { 
  :depends => [:java],
  
  :install => procedure {
    system("wget http://release.seleniumhq.org/selenium-remote-control/1.0.1/selenium-remote-control-1.0.1-dist.zip")
    system("unzip selenium*")
    system("mkdir /var/selenium")    
    system("mv selenium* /var/selenium")
    system("ln -s /var/selenium/selenium-remote-control-1.0.1 /var/selenium/remote-control")
    system("cp support/start-selenium /usr/bin/")
    system("chmod a+x /usr/bin/start-selenium")
  },
  
  :remove => procedure {
    system("rm -rf /var/selenium")
    system("rm /usr/bin/start-selenium")
  },

  :installed? => procedure {
    File.exists? '/var/selenium' and 
    File.exists? '/usr/bin/start-selenium'
  }
}
