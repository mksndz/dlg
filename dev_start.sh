#!/usr/bin/env bash

# start solr
/var/solr/solr-6.5.1/bin/./solr start
#/var/solr/solr-5.5.2/bin/./solr start
# start redis
redis-server --daemonize yes