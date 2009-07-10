require 'fileutils'
include FileUtils

class MyEmacs < Package
  depends_on :emacs, :git
  @@site_lisp_dir = "/usr/share/emacs/site-lisp"

  def install
    shell_out("git clone git://github.com/nathanial/my-site-lisp #@downloads/my-site-lisp")
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
Packages.register(:my_emacs, MyEmacs.new)

class MyKeybindings < Package
  def install
    cp "#@support/my_environment/xmodmap", "#{ENV['HOME']}/.xmodmap"
    shell_out("xmodmap #{ENV['HOME']}/.xmodmap")
  end

  def remove 
    rm_f "#{ENV['HOME']}/.xmodmap"
  end

  def installed? 
    File.exists? "#{ENV['HOME']}/.xmodmap"
  end
end
Packages.register(:my_keybindings, MyKeybindings.new)
