#!/usr/bin/env bash

# copy new schema
scp solr/schema.xml solr@sc0.galib.uga.edu:solr-6.4.1/server/solr/configsets/meta/
scp solr/solrconfig.xml solr@sc0.galib.uga.edu:solr-6.4.1/server/solr/configsets/meta/

