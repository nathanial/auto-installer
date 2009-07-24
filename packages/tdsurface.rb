require 'fileutils'
include FileUtils

class TDSurface < Package
  depends_on :mysql_server, :apache2, :svn, :git, :django, :expect
  depends_on :python_tz, :matplotlib, :mod_python, :python_mysqldb

  @@python_site_packages = 
    `python -c "from distutils.sysconfig import get_python_lib; print get_python_lib()"`.chomp

  @@password = SETTINGS[:tdsurface][:password]
  
  def install(branch='master')
    process_support_files
    create_tdsurface_directories
    download_tdsurface_project(branch)
    install_project_files
    shell_out("usermod -a -G dialout www-data")
    create_database
    restart_apache
  end

  def remove
    shell_out_force("service apache2 stop")
    rm_rf '/var/django-projects/tdsurface/'
    rm_rf '/var/matplotlib'
    rm_rf '/var/log/tdsurface'
    rm_rf '/var/www/media'
    #formerly we removed teh database, but that wasn't cool
    rm_f '/etc/apache2/conf.d/tdsurface'
    rm_f '/usr/local/bin/django-admin.py'
    shell_out_force("service apache2 start")
  end
  
  def installed?
    File.exists? '/var/django-projects/tdsurface/'
  end

  def restart_apache
    info "restarting apache"
    shell_out("service apache2 restart")
  end

  def install_project_files 
    info "installing tdsurface project files"
    cp "#@support/tdsurface/django_local_settings.py", "/var/django-projects/tdsurface/settings_local.py"
    chown("root", "www-data", ["/var/log/tdsurface"])
    cp_r "#@@python_site_packages/django/contrib/admin/media", "/var/www/media"
    cp_r "/var/django-projects/tdsurface/media","/var/www/"
    cp "#@support/tdsurface/tdsurface_apache.conf", '/etc/apache2/conf.d/tdsurface'
    chmod_R(0777, ["/var/matplotlib", "/var/log/tdsurface"])
  end

  def create_tdsurface_directories
    info "creating tdsurface directories"
    mkdir_p(['/var/django-projects', '/var/matplotlib', '/var/log/tdsurface'])
  end
  
  def download_tdsurface_project(branch)
    info "downloading tdsurface source from github"
    shell_out("git clone git@github.com:teledrill/tdsurface.git /var/django-projects/tdsurface")
    unless branch == 'master'
      shell_out("cd /var/django-projects/tdsurface && git checkout -b #{branch}")
      shell_out("cd /var/django-projects/tdsurface && git pull origin #{branch}")
    end
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
    info "creating tdsurface database"
    begin
      shell_out("""mysql --user=root --password=#@@password -e \"
CREATE DATABASE tdsurface;
CREATE USER 'tdsurface'@'localhost' IDENTIFIED BY '#@@password';
GRANT ALL PRIVILEGES ON *.* TO 'tdsurface'@'localhost';\"
""")
      shell_out("expect #@support/tdsurface/expect_script.tcl")
    rescue
      warn "could not create database or database already exists"
    end
  end

  def reinstall_database 
    remove_database
    create_database
  end
end
Packages.register(:tdsurface, TDSurface.new(:tdsurface))
