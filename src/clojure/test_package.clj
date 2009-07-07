(ns test-package
  (:use package util))

(def python-site-packages (system " python -c \"from distutils.sysconfig import get_python_lib; print get_python_lib()\""))

(defpackage python
  (defcommand install
    (aptitude -y install "python2.5"))
  (defcommand remove
    (aptitude -y remove "python2.5"))
  (defcommand installed?
    false))

(defpackage svn 
  (defcommand install 
    (aptitude -y install "python2.5"))
  (defcommand remove
    (aptitude -y remove "python2.5"))
  (defcommand installed?
    false))

(defpackage django
  (depends-on python svn)
  (defcommand install 
    (svn co "svn co http://code.djangoproject.com/svn/django/trunk/ downloads/django-trunk")
    (ln -sf (str downloads-dir "/django-trunk/django") (str python-site-packages "/django"))
    (ln -sf (str downloads-dir "/django-trunk/django/bin/django-admin.py") "/usr/local/bin"))
  (defcommand remove 
    (rm -rf (str downloads-dir "/django-trunk"))
    (rm -rf (str python-site-packages "/django"))
    (rm -rf "/usr/local/bin/django-admin.py"))
  (defcommand installed?
    (and 
     (exists? "/usr/local/bin/django-admin.py") 
     (exists? (str python-site-packages "/django"))
     (exists? "/usr/local/bin/django-admin.py"))))


(mkdir -p "blah/foo")
(assert (exists? "blah/foo"))
(rm -rf "blah")