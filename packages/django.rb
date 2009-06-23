require 'package'
require 'packages/general'

package(:django) {
  depends_on :python, :svn
  python_site_packages = `python -c "from distutils.sysconfig import get_python_lib; print get_python_lib()"`.chomp

  install {
    system("svn co http://code.djangoproject.com/svn/django/trunk/ django-trunk")
    system("ln -s `pwd`/django-trunk/django #{python_site_packages}/django")
    system("ln -s `pwd`/django-trunk/django/bin/django-admin.py /usr/local/bin")
  }

  remove {
    system("rm -rf django-trunk")
    system("rm #{python_site_packages}/django")
    system("rm /usr/local/bin/django-admin.py")
  }

  installed? {
    `which django-admin.py`.strip != ""
  }
}
