require 'fileutils'
include FileUtils

package(:tdsurface){
  depends_on [:mysql_server, :apache2, :svn, :git, :django, :expect,
              :python_tz, :matplotlib, :mod_python, :python_mysqldb]

  python_site_packages = `python -c "from distutils.sysconfig import get_python_lib; print get_python_lib()"`.chomp

  password = SETTINGS[:tdsurface][:password]

  install {
    process_support_files
    mkdir_p(['/var/django-projects', '/var/matplotlib', '/var/log/tdsurface'])
    shell_out("git clone git@github.com:teledrill/tdsurface.git /var/django-projects/tdsurface")
    cp "#@support/tdsurface/django_local_settings.py", "/var/django-projects/tdsurface/settings_local.py"
    chown("root", "www-data", ["/var/log/tdsurface"])
    cp_r "#{python_site_packages}/django/contrib/admin/media", "/var/www/media"
    cp_r "/var/django-projects/tdsurface/media","/var/www/"
    shell_out("usermod -a -G dialout www-data")
    create_database
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
    remove_database
    rm_f '/etc/apache2/conf.d/tdsurface'
    rm_f '/usr/local/bin/django-admin.py'
    system("service apache2 start")
  }

  
  installed? {
    File.exists? '/var/django-projects'
  }    
  
  reinstall lambda {
    @package.remove
    @package.install
  }

  remove_database lambda {
    system("""
    mysql --user=root --password=#{password} -e \"
       DROP DATABASE tdsurface;
       DROP USER 'tdsurface'@'localhost';\"
""")
  }
  
  create_database lambda {
    puts "create_database"
    shell_out("""mysql --user=root --password=#{password} -e \"
CREATE DATABASE tdsurface;
CREATE USER 'tdsurface'@'localhost' IDENTIFIED BY '#{password}';
GRANT ALL PRIVILEGES ON *.* TO 'tdsurface'@'localhost';\"
""")
  }

  repair_database lambda {
    @package.remove_database
    @package.create_database
    shell_out("expect #@support/tdsurface/expect_script.tcl")
  }
}

