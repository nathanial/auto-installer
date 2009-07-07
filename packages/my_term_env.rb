require 'package'
require 'packages/general'
require 'fileutils'
include FileUtils

aptitude_package(:emacs_term, 'emacs-snapshot')

package(:my_term_emacs) {
  depends_on :emacs_term, :git
  site_lisp_dir = "/usr/share/emacs/site-lisp"

  install {
    shell_out("git clone git://github.com/nathanial/my-site-lisp #@downloads/my-site-lisp")
    rm_rf "#{site_lisp_dir}"
    mv "#@downloads/my-site-lisp", "#{site_lisp_dir}"
  }
  remove {
    rm_rf "#{site_lisp_dir}"
  }

  installed? {
    File.exists? "#{site_lisp_dir}/mode-loader.el"
  }
}

meta_package(:my_term_env) {
  consists_of :my_emacs
}
