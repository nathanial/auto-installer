require 'fileutils'
include FileUtils

class MyEmacs < Package
  name :my_emacs
  depends_on :emacs, :git
  @@site_lisp_dir = "/usr/share/emacs/site-lisp"

  def install
    shell_out("git clone git@github.com:nathanial/my-site-lisp.git #@downloads/my-site-lisp")
    rm_rf "#@@site_lisp_dir"
    mv "#@downloads/my-site-lisp", "#@@site_lisp_dir"
  end

  def remove
    rm_rf "#@@site_lisp_dir"
  end
  
  def installed? 
    File.exists? "#@@site_lisp_dir/mode-loader.el"
  end
end

class MyKeybindings < Package
  name :my_keybindings
  def install
    cp "#@support/my_environment/xmodmap", "#@home/.xmodmap"
    shell_out("xmodmap #@home/.xmodmap")
  end

  def remove 
    rm_f "#@home/.xmodmap"
  end

  def installed? 
    File.exists? "#@home/.xmodmap"
  end
end
