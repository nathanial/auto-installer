require 'package'
require 'packages/general'
require 'fileutils'
include FileUtils

aptitude_package(:emacs_term, 'emacs-snapshot')

package(:my_term_emacs) do
  depends_on :emacs_term, :git
  @site_lisp_dir = "/usr/share/emacs/site-lisp"

  def install
    shell_out("git clone git://github.com/nathanial/my-site-lisp #@downloads/my-site-lisp")
    rm_rf "#@site_lisp_dir"
    mv "#@downloads/my-site-lisp", "#@site_lisp_dir"
  end

  def remove 
    rm_rf "#@site_lisp_dir"
  end

  def installed? 
    File.exists? "#@site_lisp_dir/mode-loader.el"
  end
end