mkdir /opt/solr/server/solr/configsets/meta
mkdir /opt/solr/server/solr/configsets/meta/conf
mkdir /opt/solr/server/solr/configsets/meta/conf/lang
curl https://gitlab.galileo.usg.edu/infra/solr-configs/meta/raw/master/meta/schema.xml --output /opt/solr/server/solr/configsets/meta/conf/schema.xml
curl https://gitlab.galileo.usg.edu/infra/solr-configs/meta/raw/master/meta/solrconfig.xml --output /opt/solr/server/solr/configsets/meta/conf/solrconfig.xml
curl https://gitlab.galileo.usg.edu/infra/solr-configs/meta/raw/master/meta/conf/stopwords.txt --output /opt/solr/server/solr/configsets/meta/conf/stopwords.txt
curl https://gitlab.galileo.usg.edu/infra/solr-configs/meta/raw/master/meta/conf/stopwords_en.txt --output /opt/solr/server/solr/configsets/meta/conf/stopwords_en.txt
curl https://gitlab.galileo.usg.edu/infra/solr-configs/meta/raw/master/meta/conf/synonyms.txt --output /opt/solr/server/solr/configsets/meta/conf/synonyms.txt
curl https://gitlab.galileo.usg.edu/infra/solr-configs/meta/raw/master/meta/conf/protwords.txt --output /opt/solr/server/solr/configsets/meta/conf/protwords.txt
/opt/solr/bin/solr start -p 8983
/opt/solr/bin/solr create_core -c meta-test -d meta -p 8983
/opt/solr/bin/solr stop
solr-foreground
