require 'package'
require 'packages/django'
require 'packages/general'

package :tdsurface {
  depends_on [:mysql_server, :apache2, :svn, :git, :django,
              :python_tz, :matplotlib, :mod_python, :python_mysqldb]

  install {
    system("mkdir /var/django-projects")
    system("git clone git@github.com:teledrill/tdsurface.git /var/django-projects/tdsurface")
    system("cp support/django_local_settings.py /var/django-projects/tdsurface/settings_local.py")
    system("mkdir /var/matplotlib")
    system("chmod a+rwx /var/matplotlib")
    system("mkdir /var/log/tdsurface")
    system("chown root:www-data /var/log/tdsurface")
    system("chmod a+rwx /var/log/tdsurface")
    system("cp -rf #{python_site_packages}/django/contrib/admin/media /var/www/media")
    system("cp -rf /var/django-projects/tdsurface/media /var/www/")
    system("usermod -a -G dialout www-data")
    system("""mysql --user=root --password=mosfet -e \"
CREATE DATABASE tdsurface;
CREATE USER 'tdsurface'@'localhost' IDENTIFIED BY 'mosfet';
GRANT ALL PRIVILEGES ON *.* TO 'tdsurface'@'localhost';\"
""")
    system("python /var/django-projects/tdsurface/manage.py syncdb")
    system("cp support/tdsurface_apache.conf /etc/apache2/conf.d/tdsurface")
    system("service apache2 restart")
  }

  remove {
    system("rm -rf /var/django-projects")
    system("rm -rf /var/matplotlib")
    system("rm -rf /var/log/tdsurface")
    system("rm -rf /var/www/media")
    system("""mysql --user=root --password=mosfet -e \"
DROP DATABASE tdsurface;
DROP USER 'tdsurface'@'localhost';\"
""")
    system("rm /etc/apache2/conf.d/tdsurface")
  }

  installed? => procedure {
    File.exists? '/var/django-projects'
  }    
}
