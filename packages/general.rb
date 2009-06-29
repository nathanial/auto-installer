require 'package'

aptitude_packages({
  :ant => 'ant',
  :ruby => 'ruby',
  :rubygems => 'rubygems',
  :irb => 'irb',
  :libopenssl_ruby => 'libopenssl-ruby',
  :mysql_server => 'mysql-server',
  :curl => 'curl',
  :git => 'git-core',
  :svn => 'subversion',
  :ruby => 'ruby1.8',
  :java => 'sun-java6-jdk',
  :python25 => 'python2.5',
  :python26 => 'python2.6',
  :matplotlib => 'python-matplotlib',
  :python_tz => 'python-tz',
  :emacs => 'emacs-snapshot-gtk',
  :apache2 => 'apache2',
  :mod_python => 'libapache2-mod-python',
  :python_mysqldb => 'python-mysqldb',
  :expect => 'expect'
})

package(:http_client_gem){
  depends_on :ruby, :rubygems
  install { shell_out("gem install httpclient") }
  remove { shell_out("gem remove httpclient") }
  installed? { shell_out("ruby -e \"require httpclient\"") }
}

package(:openssl_nonblock_gem){
  depends_on :ruby, :rubygems
  install { shell_out("gem install openssl-nonblock") }
  remove { shell_out("gem remove openssl-nonblock") }
  installed? { shell_out("ruby -e \"require 'httpclient'\"") }
}

package(:rspec_gem){
  depends_on :ruby, :rubygems
  install { shell_out("gem install rspec --no-rdoc") }
  remove { shell_out("gem remove rspec") }
  installed? { `which spec`.strip != '' }
}

meta_package(:python) {
  is_one_of :python25, :python26
}


