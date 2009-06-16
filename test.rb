require 'package'

aptitude_packages({:git => 'git-core',
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

add_install_hook(:git, procedure {
  system("mkdir ~/.ssh")
  system("cp support/id_rsa ~/.ssh")
  system("cp support/id_rsa.pub ~/.ssh")
  
  system("mkdir /root/.ssh")
  system("cp support/id_rsa /root/.ssh")
  system("cp support/id_rsa.pub /root/.ssh")
  system("chmod -R 700 /root/.ssh")
})

site_lisp_dir = '/usr/local/share/emacs/site-lisp'
package :my_site_lisp, {
  :depends => [:emacs, :git],
  :install => procedure {
    system("git clone git://github.com/nathanial/my-site-lisp")
    system("rm -rf #{site_lisp_dir}")
    system("mv my-site-lisp #{site_lisp_dir}")
  },
  :remove => procedure {
    raise "not implemented"
  },
  :installed? => procedure {
    File.exists? "#{site_lisp_dir}/mode-loader.el"
  }
}

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

package :django, {
  :depends => [:python, :svn],
  :install => procedure {
    system("svn co http://code.djangoproject.com/svn/django/trunk/ django-trunk")
    system("ln -s `pwd`/django-trunk/django #{python_site_packages}/django")
    system("ln -s `pwd`/django-trunk/django/bin/django-admin.py /usr/local/bin")
  },
  :remove => procedure {
    raise "not implemented"
  },
  :installed? => procedure {
    `which django-admin.py`.strip != ""
  }
}

def python_site_packages 
	`python -c "from distutils.sysconfig import get_python_lib; print get_python_lib()"`.chomp
end

package :tdsurface, {
  :depends => [:mysql_server, :apache2,
               :svn, :git, :django,
               :python_tz, :matplotlib,
               :mod_python, :python_mysqldb],

  :install => procedure {
    system("mkdir /var/django-projects")
    system("git clone git@github.com:teledrill/tdsurface.git /var/django-projects/tdsurface")
    system("cp support/django_local_settings.py /var/django-projects/tdsurface/settings_local.py")
    system("mkdir /var/matplotlib")
    system("chmod a+rwx /var/matplotlib")
    system("mkdir /var/log/tdsurface")
    system("chown root:www-data /var/log/tdsurface")
    system("chmod a+rwx /var/log/tdsurface")
    system("ln -s #{python_site_packages}/django/contrib/admin/media /var/www/media")
    system("usermod -a -G dialout www-data")
    system("""mysql --user=root --password=zoroaster22 -e \"
CREATE DATABASE tdsurface;
CREATE USER 'tdsurface'@'localhost' IDENTIFIED BY 'mosfet';
GRANT ALL PRIVILEGES ON *.* TO 'tdsurface'@'localhost';\"
""")
    system("python /var/django-projects/tdsurface/manage.py syncdb")
    system("cp support/tdsurface_apache.conf /etc/apache2/conf.d/tdsurface")
  },
  :remove => procedure {
    system("rm -rf /var/django-projects")
    system("rm -rf /var/matplotlib")
    system("rm -rf /var/log/tdsurface")
    system("rm /var/www/media")
    system("""mysql --user=root --password=zoroaster22 -e \"
DROP DATABASE tdsurface;
DROP USER 'tdsurface'@'localhost';\"
""")
    system("rm /etc/apache2/conf.d/tdsurface")
  },
  :installed? => procedure {
    false
  }    
}
