require 'package'
require 'packages/general'
require 'rubygems'
require 'httpclient'
require 'fileutils'
include FileUtils

package(:jruby) {
  depends_on :java, :git
  jruby_repo_url = "git://github.com/jruby/jruby.git"

  install {
    shell_out("git clone #{jruby_repo_url} /opt/jruby")
    shell_out("ant -f /opt/jruby/build.xml")
  }

  remove {
    rm_rf "/opt/jruby"
  }

  installed? {
    File.exists? "/opt/jruby"
  }

  define(:link_to_bin) {|x|
    ln "/opt/jruby/bin/#{x}", "/usr/local/bin/"
  }
}
