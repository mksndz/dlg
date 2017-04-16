#!/usr/bin/env bash

# clear index
curl http://metasolr.galib.uga.edu:8983/solr/blacklight-core/update --data '<delete><query>*:*</query></delete>' -H 'Content-type:text/xml; charset=utf-8'
curl http://metasolr.galib.uga.edu:8983/solr/blacklight-core/update --data '<commit/>' -H 'Content-type:text/xml; charset=utf-8'

# backup old configs
ssh solr@metasolr cp /opt/solr-5.5.2/server/solr/blacklight-core/conf/schema.xml /opt/solr-5.5.2/server/solr/blacklight-core/conf/schema.old
ssh solr@metasolr cp /opt/solr-5.5.2/server/solr/blacklight-core/conf/solrconfig.xml /opt/solr-5.5.2/server/solr/blacklight-core/conf/solrconfig.old

# copy new config
scp solr/schema.xml solr@sc0.galib.uga.edu:solr-6.4.1/server/solr/configsets/meta/
scp solr/solrconfig.xml solr@sc0.galib.uga.edu:solr-6.4.1/server/solr/configsets/meta/

# restart solr
ssh solr@metasolr /opt/solr/bin/solr restart