require 'package'

package :django, {
  :depends => [:python, :svn],
  :install => procedure {
    system("svn co http://code.djangoproject.com/svn/django/trunk/ django-trunk")
    system("ln -s `pwd`/django-trunk/django #{python_site_packages}/django")
    system("ln -s `pwd`/django-trunk/django/bin/django-admin.py /usr/local/bin")
  },
  :remove => procedure {
    raise "not implemented"
  },
  :installed? => procedure {
    `which django-admin.py`.strip != ""
  }
}