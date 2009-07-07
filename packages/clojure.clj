(defpackage clojure
  (depends-on java git ant)
  (define cojure-repo-url "git://github.com/richhickey/clojure.git")

  (install 
   (git clone clojure-repo-url "*downloads*/clojure")
   (ant -f "*downloads*/clojure/build.xml" "clojure")
   (mkdir -p "/opt/clojure/")
   (mv "*downloads*/clojure/clojure.jar" "/opt/clojure/")
   (rm -rf "*downloads*/clojure")
   (cp "*support*/clojure/clojure" "/opt/clojure/")
   (ln -sf "/opt/clojure/clojure" "/usr/local/bin/")
   (chmod "0555" "/opt/clojure/clojure/")))   