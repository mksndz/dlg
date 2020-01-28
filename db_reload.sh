#!/usr/bin/env bash

# todo: prevent this from accidentaly being run in production

rake db:drop
rake db:setup
rake sample_data