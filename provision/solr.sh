#!/bin/sh -e

# install java
echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections
echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections
apt-get -y -qq install oracle-java8-installer
update-java-alternatives -s java-8-oracle

# install solr
wget http://archive.apache.org/dist/lucene/solr/6.5.1/solr-6.5.1.tgz
tar -xvf solr-6.5.1.tgz

# copy solr config
sudo mkdir solr-6.5.1/server/solr/configsets/meta
sudo mkdir solr-6.5.1/server/solr/configsets/meta/conf
sudo mkdir solr-6.5.1/server/solr/configsets/meta/conf/lang
sudo curl https://raw.githubusercontent.com/GIL-GALILEO/solr-configs/master/meta/schema.xml --output solr-6.5.1/server/solr/configsets/meta/conf/schema.xml
sudo curl https://raw.githubusercontent.com/GIL-GALILEO/solr-configs/master/meta/solrconfig.xml --output solr-6.5.1/server/solr/configsets/meta/conf/solrconfig.xml
sudo cp solr-6.5.1/server/solr/configsets/basic_configs/conf/lang/stopwords_en.txt solr-6.5.1/server/solr/configsets/meta/conf/stopwords.txt
sudo cp solr-6.5.1/server/solr/configsets/basic_configs/conf/lang/stopwords_en.txt solr-6.5.1/server/solr/configsets/meta/conf/stopwords_en.txt
sudo cp solr-6.5.1/server/solr/configsets/basic_configs/conf/synonyms.txt solr-6.5.1/server/solr/configsets/meta/conf/synonyms.txt
sudo cp solr-6.5.1/server/solr/configsets/basic_configs/conf/protwords.txt solr-6.5.1/server/solr/configsets/meta/conf/protwords.txt

# TODO: create a solr user

# start solr, creating collection
sudo bash solr-6.5.1/bin/solr start -c -force
sudo bash solr-6.5.1/bin/solr create -c meta-dev -d meta -force
sudo bash solr-6.5.1/bin/solr create -c meta-test -d meta -force