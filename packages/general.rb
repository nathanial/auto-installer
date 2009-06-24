require 'package'

aptitude_packages({
  :git => 'git-core',
  :svn => 'subversion',
  :ruby => 'ruby1.8',
  :java => 'sun-java6-jdk',
  :mysql_server => 'mysql-server',
  :python25 => 'python2.5',
  :python26 => 'python2.6',
  :matplotlib => 'python-matplotlib',
  :python_tz => 'python-tz',
  :emacs => 'emacs-snapshot-gtk',
  :apache2 => 'apache2',
  :mod_python => 'libapache2-mod-python',
  :python_mysqldb => 'python-mysqldb'
})

meta_package(:python) {
  is_one_of :python25, :python26
}
