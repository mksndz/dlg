#!/bin/sh -e

# install java
#echo oracle-java9-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections
##echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections
#apt-get -y -qq install oracle-java9-installer
#update-java-alternatives -s java-9-oracle

# install solr
wget http://archive.apache.org/dist/lucene/solr/6.5.1/solr-6.5.1.tgz
tar -xvf solr-6.5.1.tgz

# copy solr config
mkdir solr-6.5.1/server/solr/configsets/meta
mkdir solr-6.5.1/server/solr/configsets/meta/conf
mkdir solr-6.5.1/server/solr/configsets/meta/conf/lang
curl https://raw.githubusercontent.com/GIL-GALILEO/solr-configs/master/meta/schema.xml --output solr-6.5.1/server/solr/configsets/meta/conf/schema.xml
curl https://raw.githubusercontent.com/GIL-GALILEO/solr-configs/master/meta/solrconfig.xml --output solr-6.5.1/server/solr/configsets/meta/conf/solrconfig.xml
cp solr-6.5.1/server/solr/configsets/basic_configs/conf/lang/stopwords_en.txt solr-6.5.1/server/solr/configsets/meta/conf/stopwords.txt
cp solr-6.5.1/server/solr/configsets/basic_configs/conf/lang/stopwords_en.txt solr-6.5.1/server/solr/configsets/meta/conf/stopwords_en.txt
cp solr-6.5.1/server/solr/configsets/basic_configs/conf/synonyms.txt solr-6.5.1/server/solr/configsets/meta/conf/synonyms.txt
cp solr-6.5.1/server/solr/configsets/basic_configs/conf/protwords.txt solr-6.5.1/server/solr/configsets/meta/conf/protwords.txt

# start solr, creating collection
solr-6.5.1/bin/solr start -c -force
solr-6.5.1/bin/solr create -c meta-dev -d meta -force
solr-6.5.1/bin/solr create -c meta-test -d meta -force