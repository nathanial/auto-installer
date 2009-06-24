require 'package'
require 'packages/general'
require 'packages/hudson'
require 'packages/tdsurface'

meta_package(:build_server) {
  consists_of :hudson, :tdsurface, :auto_installer
}    
