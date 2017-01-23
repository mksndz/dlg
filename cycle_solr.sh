#!/usr/bin/env bash

# project working dir
# /home/mk/Projects/meta/solr/

# solr config dirs
# /var/solr/solr-5.5.2/server/solr
# /blacklight-core
# /test-blacklight-core

# backup old solr config
mv /var/solr/solr-5.5.2/server/solr/blacklight-core/conf/solrconfig.xml /var/solr/solr-5.5.2/server/solr/blacklight-core/conf/old_solrconfig.xml
mv /var/solr/solr-5.5.2/server/solr/test-blacklight-core/conf/solrconfig.xml /var/solr/solr-5.5.2/server/solr/test-blacklight-core/conf/old_solrconfig.xml

# backup old solr schema
mv /var/solr/solr-5.5.2/server/solr/blacklight-core/conf/schema.xml /var/solr/solr-5.5.2/server/solr/blacklight-core/conf/old_schema.xml
mv /var/solr/solr-5.5.2/server/solr/test-blacklight-core/conf/schema.xml /var/solr/solr-5.5.2/server/solr/test-blacklight-core/conf/old_schema.xml

# copy new solr config
cp /home/mk/Projects/meta/solr/solrconfig.xml /var/solr/solr-5.5.2/server/solr/blacklight-core/conf/solrconfig.xml
cp /home/mk/Projects/meta/solr/solrconfig.xml /var/solr/solr-5.5.2/server/solr/test-blacklight-core/conf/solrconfig.xml

# copy new solr schema
cp /home/mk/Projects/meta/solr/schema.xml /var/solr/solr-5.5.2/server/solr/blacklight-core/conf/schema.xml
cp /home/mk/Projects/meta/solr/schema.xml /var/solr/solr-5.5.2/server/solr/test-blacklight-core/conf/schema.xml

# restart solr
/var/solr/solr-5.5.2/bin/./solr restart