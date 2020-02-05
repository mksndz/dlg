#!/usr/bin/env bash

kill -15 `cat ./pidfiles/commit_worker.pid` &
kill -15 `cat ./pidfiles/xml_worker.pid` &
kill -15 `cat ./pidfiles/xml_worker2.pid` &
kill -15 `cat ./pidfiles/reindex_worker.pid` &
kill -15 `cat ./pidfiles/optimize_worker.pid` &
kill -15 `cat ./pidfiles/fulltext_worker.pid` &
kill -15 `cat ./pidfiles/resave_worker.pid` &
kill -15 `cat ./pidfiles/page_processor_worker.pid` &

PIDFILE=./pidfiles/commit_worker.pid BACKGROUND=yes QUEUE=batch_commit_queue RAILS_ENV=production bundle exec rake resque:work
PIDFILE=./pidfiles/xml_worker.pid BACKGROUND=yes QUEUE=xml RAILS_ENV=production bundle exec rake resque:work
PIDFILE=./pidfiles/xml_worker2.pid BACKGROUND=yes QUEUE=xml RAILS_ENV=production bundle exec rake resque:work
PIDFILE=./pidfiles/reindex_worker.pid BACKGROUND=yes QUEUE=reindex RAILS_ENV=production bundle exec rake resque:work
PIDFILE=./pidfiles/optimize_worker.pid BACKGROUND=yes QUEUE=optimize RAILS_ENV=production bundle exec rake resque:work
PIDFILE=./pidfiles/fulltext_worker.pid BACKGROUND=yes QUEUE=fulltext_ingest_queue RAILS_ENV=production bundle exec rake resque:work
PIDFILE=./pidfiles/resave_worker.pid BACKGROUND=yes QUEUE=resave RAILS_ENV=production bundle exec rake resque:work
PIDFILE=./pidfiles/page_processor_worker.pid BACKGROUND=yes QUEUE=page_ingest_queue RAILS_ENV=production bundle exec rake resque:work