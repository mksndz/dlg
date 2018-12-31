# DLG Meta

A [Blacklight](https://github.com/projectblacklight/blacklight)-based administration app for the [Digital Library of Georgia](http://dlg.galileo.usg.edu/). Currently a work in progress!

See [this project on GitHub](https://github.com/GIL-GALILEO/meta)

### Developer Information

#### Requirements
+ Ruby 2.2.2
+ Rails 4.2.5
+ PostgreSQL running *(elaborate)*
+ Solr 5
+ Redis

#### Setup
1. Clone this repo
2. Copy Solr config files from `/solr` to your solr blacklight-core config dir
3. `bundle install` to install dependencies 
4. `rake jetty:start` to start Solr using Jetty
5. `rake db:create:all` to create databases *(confirm)*
6. `rake db:schema:load` to load database schema *(confirm)*
7. `rake db:seed` to load some data
8. `rails s` to start development web server
9. `./dev_start` to start Solr and Redis
9. Go to [http://localhost:3000](localhost:3000)
10. `rspec` to run all specs

### License
© 2017 Digital Library of Georgia