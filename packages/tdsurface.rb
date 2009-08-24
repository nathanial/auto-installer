require 'fileutils'
include FileUtils

class TDSurface < Package
  name :tdsurface

  depends_on :mysql_server, :apache2, :svn, :git, :django, :expect
  depends_on :python_tz, :matplotlib, :mod_python, :python_mysqldb
  depends_on :pisa, :report_lab, :python_html5lib, :pypdf, :python_imaging

  directories '/var/matplotlib', '/var/log/tdsurface'
  repository :git, "git@github.com:teledrill/tdsurface.git"
  
  @@python_site_packages = 
    `python -c "from distutils.sysconfig import get_python_lib; print get_python_lib()"`.chomp

  @@password = SETTINGS[:tdsurface][:password]

  def install
    install_project_files
    shell_out("usermod -a -G dialout www-data")
    create_database
    restart_apache
  end

  def remove
    shell_out_force("service apache2 stop")
    rm_rf '/var/www/media'
    rm_f '/etc/apache2/conf.d/tdsurface'
    shell_out_force("service apache2 start")
  end

  def restart_apache
    info "restarting apache"
    shell_out("service apache2 restart")
  end

  def install_project_files 
    info "installing tdsurface project files"
    cp "#@support/tdsurface/django_local_settings.py", "#@project_directory/settings_local.py"
    chown("root", "www-data", ["/var/log/tdsurface"])
    cp_r "#@@python_site_packages/django/contrib/admin/media", "/var/www/media"
    cp_r "#@project_directory/media","/var/www/"
    cp "#@support/tdsurface/tdsurface_apache.conf", '/etc/apache2/conf.d/tdsurface'
    chmod_R(0777, ["/var/matplotlib", "/var/log/tdsurface"])
    shell_out("touch /var/log/tdsurface/tdsurface.log")
    shell_out("chmod a+rw /var/log/tdsurface/tdsurface.log")
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
  
  def redeploy_from(directory)
    remove
    rm_rf @project_directory
    info "copying from #{directory} to #@project_directory"
    cp_r directory, @project_directory
    install
    shell_out("cd #@project_directory && DJANGO_SETTINGS_MODULE=\"settings\" python -c 'from django.contrib.sessions.models import Session; Session.objects.all().delete()'")
  end

  def complete_redeploy_from(directory)
    remove_database
    redeploy_from(directory)
    shell_out("cd #@project_directory && python manage.py loaddata fixtures/test_well.json")
  end

  def cdf_and_sim(directory)
    complete_redeploy_from(directory)
    shell_out("cd #{MWDSim.project_directory} && python mwd_sim.py")
  end
end
