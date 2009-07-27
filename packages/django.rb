require 'fileutils'
include FileUtils

class Django < Package
  name :django
  depends_on :python, :svn
  repository :svn, "http://code.djangoproject.com/svn/django/trunk/"
  @@python_site_packages = `python -c "from distutils.sysconfig import get_python_lib; print get_python_lib()"`.chomp

  def install 
    rm_rf "#@@python_site_packages/django"
    mv "#@project_directory/django", "#@@python_site_packages/django", :force => true
    ln_sf "#@@python_site_packages/django/bin/django-admin.py", "/usr/local/bin"
  end

  def remove 
    rm_rf "#@@python_site_packages/django"
    rm_rf '/usr/local/bin/django-admin.py'
  end

  def installed?
    File.exists? "#@python_site_packages/django"
  end
end
