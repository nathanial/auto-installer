
package(:auto_installer) do
  depends_on :git, :ruby, :rubygems, :irb
  depends_on :libopenssl_ruby, :http_client_gem
  depends_on :openssl_nonblock_gem

  def install 
    ln_s "#@home/package", "/usr/local/bin/package"
  end

  def remove 
    rm "/usr/local/bin/package"
  end
  
  def installed? 
    File.exists? "/usr/local/bin/package"
  end
end
    
