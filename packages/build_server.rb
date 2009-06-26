require 'package'
require 'packages/general'
require 'packages/hudson'
require 'packages/tdsurface'
require 'packages/auto_installer'

meta_package(:build_server) {
  consists_of :hudson, :auto_installer, :tdsurface
  after_install {
    shell_out("aptitude -y install curl")
    shell_out("curl -d@#@support/hudson/config.xml -H \"Content-Type: text/xml\" \"http://localhost:8080/createItem?name=autoinstaller\"")
  }
}    
