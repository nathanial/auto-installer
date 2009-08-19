require 'rubygems'
require 'httpclient'
require 'fileutils'
include FileUtils

class JRuby < Package
  name :jruby
  depends_on :java, :git
  repository :git, "git://github.com/jruby/jruby.git"

  def install
    shell_out("ant -f #@project_directory/build.xml")
  end
end
