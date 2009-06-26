require 'package'
require 'packages/general'
require 'packages/hudson'
require 'packages/tdsurface'
require 'packages/auto_installer'

package(:build_server) {
  depends_on :hudson, :tdsurface, :curl
  
  install {
    retry_count = 10
    tries = 0
    finished = false
    while (tries < retry_count) and not finished
      begin
        shell_out("curl -d@#@support/hudson/config.xml -H \"Content-Type: text/xml\" \"http://localhost:8080/createItem?name=autoinstaller\"")
      rescue
        tries += 1
        finished = false
      end
      finished = true
    end
  }
}    
