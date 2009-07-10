require 'fileutils'
include FileUtils

package(:django) do
  depends_on :python, :svn
  @python_site_packages = `python -c "from distutils.sysconfig import get_python_lib; print get_python_lib()"`.chomp

  def install 
    shell_out("svn co http://code.djangoproject.com/svn/django/trunk/ #@downloads/django-trunk")
    ln_sf "#@downloads/django-trunk/django", "#@python_site_packages/django"
    ln_sf "#@downloads/django-trunk/django/bin/django-admin.py", "/usr/local/bin"
  end

  def remove 
    rm_rf '#@downloads/django-trunk'
    rm_rf "#@python_site_packages/django"
    rm_rf '/usr/local/bin/django-admin.py'
  end

  def installed?
    File.exists? '/usr/local/bin/django-admin.py' and 
    File.exists? "#@python_site_packages/django" and
    File.exists? '/usr/local/bin/django-admin.py'
  end
end
