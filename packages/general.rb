require 'package'

aptitude_packages({ :git => 'git-core',
                    :svn => 'subversion',
                    :ruby => 'ruby1.8',
                    :java => 'sun-java6-jdk',
                    :mysql_server => 'mysql-server',
                    :python25 => 'python2.5',
                    :python26 => 'python2.6',
                    :matplotlib => 'python-matplotlib',
                    :python_tz => 'python-tz',
                    :emacs => 'emacs-snapshot-gtk',
                    :apache2 => 'apache2',
                    :mod_python => 'libapache2-mod-python',
                    :python_mysqldb => 'python-mysqldb'})

add_install_hook(:git, procedure {
  system("mkdir ~/.ssh")
  system("cp support/id_rsa ~/.ssh")
  system("cp support/id_rsa.pub ~/.ssh")
  
  system("mkdir /root/.ssh")
  system("cp support/id_rsa /root/.ssh")
  system("cp support/id_rsa.pub /root/.ssh")
  system("chmod -R 700 /root/.ssh")
})

meta_package :python, {
  :install => procedure {
    Package.install(:python25)
  },
  :remove => procedure {
    Package.remove(:python25) if Package.installed?(:python25)
    Package.remove(:python26) if Package.installed?(:python26)
  },
  :installed? => procedure {
    Package.installed?(:python25) or 
    Package.installed?(:python26)
  }	
}

def python_site_packages 
  `python -c "from distutils.sysconfig import get_python_lib; print get_python_lib()"`.chomp
end
