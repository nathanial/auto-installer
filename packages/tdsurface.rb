require 'fileutils'
include FileUtils

class TDSurface < Package
  depends_on :mysql_server, :apache2, :svn, :git, :django, :expect
  depends_on :python_tz, :matplotlib, :mod_python, :python_mysqldb

  @@python_site_packages = 
    `python -c "from distutils.sysconfig import get_python_lib; print get_python_lib()"`.chomp

  @@password = SETTINGS[:tdsurface][:password]
  
  def install
    process_support_files
    mkdir_p(['/var/django-projects', '/var/matplotlib', '/var/log/tdsurface'])
    shell_out("git clone git@github.com:teledrill/tdsurface.git /var/django-projects/tdsurface")
    cp "#@support/tdsurface/django_local_settings.py", "/var/django-projects/tdsurface/settings_local.py"
    chown("root", "www-data", ["/var/log/tdsurface"])
    cp_r "#@@python_site_packages/django/contrib/admin/media", "/var/www/media"
    cp_r "/var/django-projects/tdsurface/media","/var/www/"
    shell_out("usermod -a -G dialout www-data")
    create_database
    shell_out("expect #@support/tdsurface/expect_script.tcl")
    cp "#@support/tdsurface/tdsurface_apache.conf", '/etc/apache2/conf.d/tdsurface'
    chmod_R(0777, ["/var/matplotlib", "/var/log/tdsurface"])
    shell_out("service apache2 restart")
  end

  def remove
    system("service apache2 stop")
    rm_rf '/var/django-projects'
    rm_rf '/var/matplotlib'
    rm_rf '/var/log/tdsurface'
    rm_rf '/var/www/media'
    remove_database
    rm_f '/etc/apache2/conf.d/tdsurface'
    rm_f '/usr/local/bin/django-admin.py'
    system("service apache2 start")
  end

  
  def installed?
    File.exists? '/var/django-projects'
  end
  
  def reinstall 
    remove
    install
  end

  def remove_database
    system("""
    mysql --user=root --password=#@@password -e \"
       DROP DATABASE tdsurface;
       DROP USER 'tdsurface'@'localhost';\"
""")
  end
  
  def create_database 
    puts "create_database"
    shell_out("""mysql --user=root --password=#@@password -e \"
CREATE DATABASE tdsurface;
CREATE USER 'tdsurface'@'localhost' IDENTIFIED BY '#@@password';
GRANT ALL PRIVILEGES ON *.* TO 'tdsurface'@'localhost';\"
""")
  end

  def repair_database 
    remove_database
    create_database
    shell_out("expect #@support/tdsurface/expect_script.tcl")
  end
end
Packages.register(:tdsurface, TDSurface.new(:tdsurface))
