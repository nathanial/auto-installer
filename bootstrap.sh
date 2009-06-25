#!/bin/sh

if [ "$(whoami)" != "root" ]
then
    echo "must be root to run this script"
    exit 1
fi

aptitude -y install ruby rubygems irb
gem install httpclient
