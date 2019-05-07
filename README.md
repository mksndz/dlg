# DLG Meta

A [Blacklight](https://github.com/projectblacklight/blacklight)-based administration app for the [Digital Library of Georgia](http://dlg.galileo.usg.edu/). Currently a work in progress!

See [this project on GitHub](https://github.com/GIL-GALILEO/meta)

### Developer Information

#### Requirements
+ Ruby 2.3.4
+ Rails 4.2.5
+ PostgreSQL running *(elaborate)*
+ Solr 6
+ Redis 4

#### Setup
1. Clone this repo
2. Install ruby 2.3.4, vagrant(needs VirtualBox)
3. `bundle install` to install gem dependencies 
4. add secrets.yml to the config/ directory (need to get from one of the developers)
5. `vagrant up` to start the VM which is running Postgres, Redis, and Solr
5. `rake db:setup` to create databases
6. `rake sample_data` to load some data
7. `rails s` to start development web server
8. Go to [http://localhost:3000](localhost:3000)
9. Sign in with the test user (email: super@uga.edu, password: password)
10. Search for `georgia` to make sure the seed data was loaded correctly

#### Test Suite
1. `bundle exec rake db:test:prepare` to setup the meta_test database
2. `rspec` to run all specs


### License
© 2019 Digital Library of Georgia