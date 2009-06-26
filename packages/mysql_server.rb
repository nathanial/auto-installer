require 'package'
require 'packages/general'

package(:mysql_server) {
  depends_on :expect
  install {
    shell_out("expect #@support/mysql_server/expect_script.tcl") 
  }
  remove {
    shell_out("aptitude -y remove mysql-server")    
  }
  installed? {
    search_results = `aptitude search mysql-server`
    installed = search_results.reject {|r| not r =~ /^i/}
    not installed.empty?
  }
}

