#!/bin/bash
groupadd -g 999 gitlab-runner && useradd -u 999 -g 999 gitlab-runner && usermod -d /code gitlab-runner
apt-get update -qq && apt-get -y install nodejs sudo
sudo -u gitlab-runner wget --quiet https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-2.1.1-linux-x86_64.tar.bz2
sudo -u gitlab-runner tar xjf phantomjs-2.1.1-linux-x86_64.tar.bz2
cp phantomjs-2.1.1-linux-x86_64/bin/phantomjs /bin/
# Workaround for phantomjs openssl issue
# https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=918727
export OPENSSL_CONF=/dev/null
HOME=/code gem install bundler
HOME=/code bundle install
cp /code/config/database.yml.ci /code/config/database.yml
cp /code/config/blacklight.yml.ci /code/config/blacklight.yml
cp /code/config/secrets.yml.ci /code/config/secrets.yml
HOME=/code bundle config --global jobs=8
HOME=/code bundle exec rake db:setup RAILS_ENV=test
chown -R gitlab-runner:gitlab-runner /code
sudo -E -u gitlab-runner bundle exec rspec --color --format documentation
