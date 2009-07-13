require 'rubygems'
require 'httpclient'
require 'fileutils'
include FileUtils

class Clojure < Package
  depends_on :java, :git, :ant
  @@clojure_repo_url = "git://github.com/richhickey/clojure.git"
  
  def install 
    puts "git clone #@@clojure_repo_url #@downloads/clojure"
    shell_out("git clone #@@clojure_repo_url #@downloads/clojure")
    shell_out("ant -f #@downloads/clojure/build.xml clojure")
    mkdir_p "/opt/clojure/"
    mv "#@downloads/clojure/clojure.jar", "/opt/clojure/"
    rm_rf "#@downloads/clojure"
    cp "#@support/clojure/clojure", "/opt/clojure/"
    ln_sf "/opt/clojure/clojure", "/usr/local/bin/"
    chmod 0555, "/opt/clojure/clojure"
  end

  def remove 
    rm_rf "/opt/clojure/"
    rm_f "/usr/local/bin/clojure"
  end

  def installed? 
    File.exists? "/opt/clojure/"
  end
end
Packages.register(:clojure, Clojure.new(:clojure))
