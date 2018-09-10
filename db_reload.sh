#!/usr/bin/env bash

rake db:drop
rake db:setup
rake sample_data