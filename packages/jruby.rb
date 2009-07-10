require 'rubygems'
require 'httpclient'
require 'fileutils'
include FileUtils

package(:jruby) do
  depends_on :java, :git
  @jruby_repo_url = "git://github.com/jruby/jruby.git"

  def install
    shell_out("git clone #{jruby_repo_url} /opt/jruby")
    shell_out("ant -f /opt/jruby/build.xml")
  end

  def remove 
    rm_rf "/opt/jruby"
  end

  def installed? 
    File.exists? "/opt/jruby"
  end

end
