require 'package'
require 'packages/general'
require 'packages/hudson'
require 'packages/tdsurface'
require 'packages/auto_installer'

package(:build_server) {
  depends_on :hudson, :tdsurface, :curl
  
  install {
    client = HTTPClient.new
    client.post('http://localhost:8080/createItem?name=autoinstaller', 
                File.open("#@support/hudson/config.xml").read,
                {'Content-Type' => 'text/xml'})
  }
}    
