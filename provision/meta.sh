#!/bin/bash

cd /opt/meta
rake db:setup
rake db:migrate
rake sample_data