require 'package'
require 'packages/general'

package(:my_emacs) {
  depends_on :emacs, :git
  site_lisp_dir = "/usr/share/emacs/site-lisp"
  install {
    system("git clone git://github.com/nathanial/my-site-lisp")
    system("rm -rf #{site_lisp_dir}")
    system("mv my-site-lisp #{site_lisp_dir}")
  }
  remove {
    raise "not implemented"
  }
  installed? {
    File.exists? "#{site_lisp_dir}/mode-loader.el"
  }
}

package :my_keybindings {
  install {
    system("cp support/xmodmap ~/.xmodmap")
    system("xmodmap ~/.xmodmap")
  }    
  remove {
    system("rm ~/.xmodmap")
  }
  installed? {
    File.exists? "~/.xmodmap"
  }
}

meta_package :my_environment {
  consists_of :my_emacs, :my_keybindings
}
