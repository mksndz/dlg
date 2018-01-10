#!/bin/bash

cd /opt/meta

# build db
rake db:setup

# seed db
rake db:seed
rake sample_data