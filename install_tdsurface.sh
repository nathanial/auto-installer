#!/bin/sh

aptitude -y install git-core
aptitude -y install ruby
git clone git://github.com/nathanial/auto-installer.git
cd auto-installer
ruby -e "
require 'package'
require 'packages/general'
require 'packages/django'
Package.run_install_hooks(:git)
Package.install(:tdsurface)
"
