require 'fileutils'
include FileUtils

class Compojure < Package
  name :compojure
  depends_on :clojure
  repository :git, "git://github.com/weavejester/compojure.git"
  
  def install 
    shell_out("ant -f #@project_directory/build.xml deps")
    shell_out("ant -f #@project_directory/build.xml")
    mkdir_p "/usr/local/lib/clojure"
    cp "#@project_directory/compojure.jar", "/usr/local/lib/clojure/"
    cp "#@support/compojure/compojure", "/usr/local/bin/"
    cp_r "#@project_directory/deps", "/usr/local/lib/clojure/deps"
    chmod 0555, "/usr/local/bin/compojure"
  end

  def remove
    rm_f "/usr/local/lib/clojure/compojure.jar"
    rm_f "/usr/local/bin/compojure"
    rm_rf "/usr/local/lib/clojure/deps"
  end
end
