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
  :expect => 'expect',
  :python_serial => 'python-serial'                    
})

gem_package(:http_client_gem, :gem => 'httpclient')
gem_package(:openssl_nonblock_gem, :gem => 'openssl-nonblock')

class RSpecGem < Package
  name :rspec_gem
  depends_on :ruby, :rubygems

  def install 
    shell_out("gem install rspec --no-rdoc") 
    shell_out("aptitude -y install librspec-ruby1.8")
  end

  def remove 
    shell_out("gem uninstall rspec") 
    shell_out("aptitude -y remove librspec-ruby1.8")
  end

  def installed?
    `which spec`.strip != ''
  end
end

class Python < Package
  name :python

  def installed?
    some([:python25, :python26], lambda {|p| Packages.installed? p})
  end

  def install 
    Packages.install :python25
  end

  def remove
    "do nothing"
  end
end
      


