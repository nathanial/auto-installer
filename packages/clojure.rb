require 'rubygems'
require 'httpclient'
require 'fileutils'
include FileUtils

class Clojure < Package
  name :clojure
  depends_on :java, :git, :ant
  @@clojure_repo_url = "git://github.com/richhickey/clojure.git"
  @@root_directory = SETTINGS[:package][:directory]
  @@project_directory = "#@@root_directory/clojure"

  def install 
    debug "git clone #@@clojure_repo_url #{Package.downloads}/clojure"
    shell_out("git clone #@@clojure_repo_url #{Package.downloads}/clojure")
    shell_out("ant -f #{Package.downloads}/clojure/build.xml clojure")
    mkdir_p @@project_directory
    mv "#{Package.downloads}/clojure/clojure.jar", @@project_directory
    rm_rf "#{Package.downloads}/clojure"
    cp "#{Package.support}/clojure/clojure", @@project_directory
    ln_sf "#@@project_directory/clojure", "/usr/local/bin/"
    chmod 0555, "#@@project_directory/clojure"
  end

  def remove 
    rm_rf @@project_directory
    rm_f "/usr/local/bin/clojure"
  end

  def installed? 
    File.exists? @@project_directory
  end
end
