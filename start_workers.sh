#!/usr/bin/env bash

PIDFILE=./legacy_import_worker.pid BACKGROUND=yes QUEUE=items RAILS_ENV=production bundle exec rake resque:work
PIDFILE=./commit_worker.pid BACKGROUND=yes QUEUE=batch_commit_queue RAILS_ENV=production bundle exec rake resque:work
PIDFILE=./xml_worker.pid BACKGROUND=yes QUEUE=xml RAILS_ENV=production bundle exec rake resque:work
PIDFILE=./reindex_worker.pid BACKGROUND=yes QUEUE=reindex RAILS_ENV=production bundle exec rake resque:work