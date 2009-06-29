require 'package'
require 'packages/general'
require 'packages/hudson'
require 'packages/tdsurface'
require 'packages/auto_installer'

package(:build_server) {
  depends_on :hudson, :tdsurface, :rspec_gem
  
  install {
    client = HTTPClient.new
    client.post('http://localhost:8080/createItem?name=autoinstaller', 
                File.open("#@support/hudson/auto-installer-config.xml").read,
                {'Content-Type' => 'text/xml'})
    client.post('http://localhost:8080/createItem?name=tdsurface',
                File.open("#@support/hudson/tdsurface-config.xml").read,
                {'Content-Type' => 'text/xml'})
  }
}    
