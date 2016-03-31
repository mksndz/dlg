# Digital Library of Georgia

A [Blacklight](https://github.com/projectblacklight/blacklight)-based app for the [Digital Library of Georgia](http://dlg.galileo.usg.edu/). Currently a work in progress!

### Developer Information

#### Requirements
+ Ruby 2.2.2
+ Rails 4.2.5
+ PostgresSQL running *elaborate*
+ Java (for Solr) see [Blacklight Quickstart](https://github.com/projectblacklight/blacklight/wiki/Quickstart)

#### Setup
1. Clone this repo
2. `rake jetty:start` to start Solr using Jetty
3. `rake db:create:all` to create databases *confirm*
4. `rake db:schema:load` to load database schema *confirm*
5. `rake db:seed` to load some data
6. `rails s` to start development web server
7. [http://localhost.3000](localhost:3000) now 

### License
© 2016 Digital Library of Georgia