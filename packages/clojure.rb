require 'rubygems'
require 'httpclient'
require 'fileutils'
include FileUtils

class Clojure < Package
  name :clojure
  depends_on :java, :git, :ant
  repository :git, "git://github.com/richhickey/clojure.git"

  def install 
    shell_out("ant -f #@project_directory/build.xml clojure")
    cp "#@support/clojure/clojure", "/usr/local/bin/"
    chmod 0555, "/usr/local/bin/clojure"
  end

  def remove 
    rm_f "/usr/local/bin/clojure"
  end
end
