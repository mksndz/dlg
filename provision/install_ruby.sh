#!/usr/bin/env bash

source /home/vagrant/.rvm/scripts/rvm

rvm use --default --install $1

shift

if (( $# ))
then gem install $@
fi

rvm cleanup all

gem install bundler

cd /opt/meta

# install gems
bundle install