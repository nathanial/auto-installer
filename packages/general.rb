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

gem_package(:http_client_gem, 'httpclient') do
  depends_on :ruby, :rubygems
end

gem_package(:openssl_nonblock_gem, 'openssl-nonblock') do
  depends_on :ruby, :rubygems
end

package(:rspec_gem) do
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

package(:python) do 
  def installed?
    some([:python25, :python26], lambda {|p| Package.installed? p})
  end

  def install 
    Packages.install :python25
  end

  def remove
    "do nothing"
  end
end
    
      


