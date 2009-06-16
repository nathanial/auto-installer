require 'package'

site_lisp_dir = '/usr/local/share/emacs/site-lisp'
package :my_emacs, {
  :depends => [:emacs, :git],
  :install => procedure {
    system("git clone git://github.com/nathanial/my-site-lisp")
    system("rm -rf #{site_lisp_dir}")
    system("mv my-site-lisp #{site_lisp_dir}")
  },
  :remove => procedure {
    raise "not implemented"
  },
  :installed? => procedure {
    File.exists? "#{site_lisp_dir}/mode-loader.el"
  }
}

package :my_keybindings, {
  :depends => [],
  :install => procedure {
    system("cp support/xmodmap ~/.xmodmap")
    system("xmodmap ~/.xmodmap")
  },
  :remove => procedure {
    system("rm ~/.xmodmap")
  },
  :installed? => procedure {
    File.exists? "~/.xmodmap"
  }
}

package :my_environment, {
  :depends => [:my_emacs, :my_keybindings]
}
