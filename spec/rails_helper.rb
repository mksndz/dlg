# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?
require 'spec_helper'
require 'rspec/rails'
require 'capybara/rspec'
require 'paper_trail/frameworks/rspec'
require 'capybara-screenshot/rspec'
require 'capybara/poltergeist'

# Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!

  config.include Devise::Test::ControllerHelpers, type: :controller

  # clean up DB & Solr index before test suite
  config.before(:suite) do
    # User.destroy_all
    # Feature.destroy_all
    # FulltextIngest.destroy_all
    # BatchImport.destroy_all
    # BatchItem.destroy_all
    # Batch.destroy_all
    # Item.destroy_all
    # ItemVersion.destroy_all
    # Collection.destroy_all
    # Repository.destroy_all
    # Portal.destroy_all
    # HoldingInstitution.destroy_all
    # Project.destroy_all
    Dir[Rails.root.join('app/models/*.rb').to_s].each do |filename|
      klass = File.basename(filename, '.rb').camelize.constantize
      next unless klass.ancestors.include?(ActiveRecord::Base)
      next if klass.abstract_class?
      ActiveRecord::Base.connection.execute("TRUNCATE TABLE #{klass.table_name} RESTART IDENTITY CASCADE")
    end
  end

  config.before(:all) do
    Sunspot.remove_all! Item
    Sunspot.remove_all! Collection
  end

  # JS driver madness
  Capybara.register_driver :poltergeist do |app|
    Capybara::Poltergeist::Driver.new(app, timeout: 60)
  end
  Capybara.javascript_driver = :poltergeist

end
