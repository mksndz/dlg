#!/usr/bin/env bash

kill -9 `cat legacy_import_worker.pid`
kill -9 `cat commit_worker.pid`
kill -9 `cat xml_worker.pid`
kill -9 `cat reindex_worker.pid`

PIDFILE=./legacy_import_worker.pid BACKGROUND=yes QUEUE=items RAILS_ENV=production bundle exec rake resque:work
PIDFILE=./commit_worker.pid BACKGROUND=yes QUEUE=batch_commit_queue RAILS_ENV=production bundle exec rake resque:work
PIDFILE=./xml_worker.pid BACKGROUND=yes QUEUE=xml RAILS_ENV=production bundle exec rake resque:work
PIDFILE=./reindex_worker.pid BACKGROUND=yes QUEUE=reindex RAILS_ENV=production bundle exec rake resque:work