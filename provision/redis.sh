#!/usr/bin/env bash

wget http://download.redis.io/releases/redis-4.0.6.tar.gz
tar -xvf redis-4.0.6.tar.gz
cd redis-4.0.6
make

src/redis-server --daemonize yes --protected-mode no
