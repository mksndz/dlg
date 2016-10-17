require 'rails_helper'
include Warden::Test::Helpers
Warden.test_mode!

feature 'Batch Importing Stuff' do

  let(:super_user) { Fabricate :super }
  let(:basic_user) { Fabricate :basic }
  let(:coordinator_user) { Fabricate :coordinator }
  let(:committer_user) { Fabricate :committer }
  let(:uploader_user) { Fabricate :uploader}

  let(:batch) { Fabricate :batch }
  let(:batch_import) { Fabricate :batch_import }
  let(:completed_batch_import) { Fabricate :completed_batch_import }

  context :uploader_user do

    before :each do
      login_as super_user, scope: :user
    end

    # todo

  end

end