require 'package'
require 'packages/django'
require 'packages/general'
require 'fileutils'
include FileUtils

package(:tdsurface) {
  depends_on [:mysql_server, :apache2, :svn, :git, :django, :expect,
              :python_tz, :matplotlib, :mod_python, :python_mysqldb]

  python_site_packages = `python -c "from distutils.sysconfig import get_python_lib; print get_python_lib()"`.chomp

  install {
    mkdir_p(['/var/django-projects', '/var/matplotlib', '/var/log/tdsurface'])
    shell_out("git clone git@github.com:teledrill/tdsurface.git /var/django-projects/tdsurface")
    cp "#@support/tdsurface/django_local_settings.py", "/var/django-projects/tdsurface/settings_local.py"
    chown("root", "www-data", ["/var/log/tdsurface"])
    cp_r "#{python_site_packages}/django/contrib/admin/media", "/var/www/media"
    cp_r "/var/django-projects/tdsurface/media","/var/www/"
    shell_out("usermod -a -G dialout www-data")
    shell_out("""mysql --user=root --password=mosfet -e \"
CREATE DATABASE tdsurface;
CREATE USER 'tdsurface'@'localhost' IDENTIFIED BY 'mosfet';
GRANT ALL PRIVILEGES ON *.* TO 'tdsurface'@'localhost';\"
""")
    shell_out("expect #@support/tdsurface/expect_script.tcl")
    cp "#@support/tdsurface/tdsurface_apache.conf", '/etc/apache2/conf.d/tdsurface'
    chmod_R(0777, ["/var/matplotlib", "/var/log/tdsurface"])
    shell_out("service apache2 restart")
  }

  remove {
    puts "removing tdsurface"
    shell_out("service apache2 stop")
    rm_rf '/var/django-projects'
    rm_rf '/var/matplotlib'
    rm_rf '/var/log/tdsurface'
    rm_rf '/var/www/media'
    shell_out("""
    mysql --user=root --password=scimitar1 -e \"
       DROP DATABASE tdsurface;
       DROP USER 'tdsurface'@'localhost';\"
""")
    rm_f '/etc/apache2/conf.d/tdsurface'
    rm_f '/usr/local/bin/django-admin.py'
    shell_out("service apache2 start")
  }

  installed? {
    File.exists? '/var/django-projects'
  }    
}
