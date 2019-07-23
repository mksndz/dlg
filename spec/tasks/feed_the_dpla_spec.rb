# frozen_string_literal: true

require 'rails_helper'
require 'rake'

describe 'DPLA Harvest Task' do
  # # Useful when testing changes to or errors with DPLA Feed task
  # before do
  #   Meta::Application.load_tasks
  #   Rake::Task.define_task :environment
  # end
  # it 'uploads files to DPLA S3 bucket' do
  #   item = Fabricate :item_with_parents, public: true, dpla: true
  #   item.repository.public = true
  #   item.repository.save
  #   item.collection.public = true
  #   item.collection.save
  #   Item.reindex
  #   Sunspot.commit
  #   expect(Rake::Task['feed_the_dpla'].invoke('1')).to be_truthy
  # end
end