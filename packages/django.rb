require 'fileutils'
include FileUtils

class Django < Package
  depends_on :python, :svn
  @@python_site_packages = `python -c "from distutils.sysconfig import get_python_lib; print get_python_lib()"`.chomp

  def install 
    shell_out("svn co http://code.djangoproject.com/svn/django/trunk/ #@downloads/django-trunk")
    rm_rf "#@@python_site_packages/django"
    mv "#@downloads/django-trunk/django", "#@@python_site_packages/django", :force => true
    ln_sf "#@@python_site_packages/django/bin/django-admin.py", "/usr/local/bin"
  end

  def remove 
    rm_rf "#@@python_site_packages/django"
    rm_rf '/usr/local/bin/django-admin.py'
  end

  def installed?
    File.exists? "#@@python_site_packages/django"
  end
end
Packages.register(:django, Django.new(:django))
