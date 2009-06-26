require 'package'
require 'packages/general'

package(:auto_installer) {
  depends_on [:git, :ruby, :rubygems, :irb,
              :libopenssl_ruby, :http_client_gem,
              :openssl_nonblock_gem]

  install {
    ln_s "#@home/package", "/usr/local/bin/package"
  }

  remove {
    rm "/usr/local/bin/package"
  }
  
  installed? {
    File.exists? "/usr/local/bin/package"
  }
}
    
