#!/bin/sh

if [ "$(whoami)" != "root" ]
then
    echo "must be root to run this script"
    exit 1
fi

mkdir -p downloads
aptitude -y install ruby rubygems irb libopenssl-ruby sysvconfig librexml-ruby
gem install httpclient
ln -s $(pwd)/package /usr/local/bin/package
