#!/bin/sh

aptitude -y install git-core
aptitude -y install irb
git clone git://github.com:nathanial/auto-installer.git
cd auto-installer
ruby -e "require 'test'; Package.install(:tdsurface)"