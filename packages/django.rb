require 'package'
require 'packages/general'
require 'fileutils'
include FileUtils

package(:django) {
  depends_on :python, :svn
  python_site_packages = `python -c "from distutils.sysconfig import get_python_lib; print get_python_lib()"`.chomp

  install {
    shell_out("svn co http://code.djangoproject.com/svn/django/trunk/ #@downloads/django-trunk")
    ln_sf "#@downloads/django-trunk/django", "#{python_site_packages}/django"
    ln_sf "#@downloads/django-trunk/django/bin/django-admin.py", "/usr/local/bin"
  }

  remove {
    rm_rf '#@downloads/django-trunk'
    rm "#{python_site_packages}/django"
    rm '/usr/local/bin/django-admin.py'
  }

  installed? {
    File.exists? '/usr/local/bin/django-admin.py'
  }
}
