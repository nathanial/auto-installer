require 'rubygems'
require 'httpclient'
require 'fileutils'
include FileUtils

class JRuby < Package
  name :jruby
  depends_on :java, :git
  @@jruby_repo_url = "git://github.com/jruby/jruby.git"

  def install
    shell_out("git clone #@@jruby_repo_url #@project_directory")
    shell_out("ant -f #@project_directory/build.xml")
  end

  def remove 
    rm_rf @project_directory
  end

  def installed? 
    File.exists? @project_directory
  end
end
