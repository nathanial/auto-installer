require 'package'
require 'packages/general'
require 'fileutils'
include FileUtils

package(:my_emacs) {
  depends_on :emacs, :git
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

package(:my_keybindings) {
  install {
    cp "#@support/my_environment/xmodmap", "#{ENV['HOME']}/.xmodmap"
    shell_out("xmodmap #{ENV['HOME']}/.xmodmap")
  }    
  remove {
    rm_f "#{ENV['HOME']}/.xmodmap"
  }
  installed? {
    File.exists? "#{ENV['HOME']}/.xmodmap"
  }
}

meta_package(:my_environment) {
  consists_of :my_emacs, :my_keybindings
}
