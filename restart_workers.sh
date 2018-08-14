#!/usr/bin/env bash

kill -9 `cat commit_worker.pid`
kill -9 `cat xml_worker.pid`
kill -9 `cat reindex_worker.pid`
kill -9 `cat optimize_worker.pid`
kill -9 `cat fulltext_worker.pid`
kill -9 `cat resave_worker.pid`

PIDFILE=./commit_worker.pid BACKGROUND=yes QUEUE=batch_commit_queue RAILS_ENV=production bundle exec rake resque:work
PIDFILE=./xml_worker.pid BACKGROUND=yes COUNT=2 QUEUE=xml RAILS_ENV=production bundle exec rake resque:work
PIDFILE=./reindex_worker.pid BACKGROUND=yes QUEUE=reindex RAILS_ENV=production bundle exec rake resque:work
PIDFILE=./optimize_worker.pid BACKGROUND=yes QUEUE=optimize RAILS_ENV=production bundle exec rake resque:work
PIDFILE=./fulltext_worker.pid BACKGROUND=yes QUEUE=fulltext_ingest_queue RAILS_ENV=production bundle exec rake resque:work
PIDFILE=./resave_worker.pid BACKGROUND=yes QUEUE=resave RAILS_ENV=production bundle exec rake resque:work