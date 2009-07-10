require 'package'
require 'packages/general'
require 'rubygems'
require 'httpclient'
require 'fileutils'
include FileUtils

package(:clojure) {
  depends_on :java, :git, :ant
  clojure_repo_url = "git://github.com/richhickey/clojure.git"
  
  install {
    shell_out("git clone #{clojure_repo_url} #@downloads/clojure")
    shell_out("ant -f #@downloads/clojure/build.xml clojure")
    mkdir_p "/opt/clojure/"
    mv "#@downloads/clojure/clojure.jar", "/opt/clojure/"
    rm_rf "#@downloads/clojure"
    cp "#@support/clojure/clojure", "/opt/clojure/"
    ln_sf "/opt/clojure/clojure", "/usr/local/bin/"
    chmod 0555, "/opt/clojure/clojure"
  }

  remove {
    rm_rf "/opt/clojure/"
    rm_f "/usr/local/bin/clojure"
  }

  installed? {
    File.exists? "/opt/clojure/"
  }
}

package(:clojure) {
  depends_on :java, :git, :ant
  clojure_repo_url = "git://github.com/richhickey/clojure.git"
  
  install {
    Git.clone clojure_repo_url, "#@downloads/clojure"
    Ant.build "#@downloads/clojure/build.xml", "clojure"
    Dir.make "/opt/clojure"
    File.move "#@downloads/clojure/clojure.jar", "/opt/clojure/"
    File.remove "#@downloads/clojure"
    File.copy "#@support/clojure/clojure", "/op/clojure/"
    File.symlink "/opt/clojure/clojure", "/usr/local/bin/"
    File.chmod 0555, "/opt/clojure/clojure"
  }
  
  remove {
    File.remove "/opt/clojure/"
    File.remove "/usr/local/bin/clojure"
  }

  installed? {
    File.exists? "/opt/clojure/"
  }
}
