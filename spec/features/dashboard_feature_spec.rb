# require 'rails_helper'
# include Warden::Test::Helpers
# Warden.test_mode!
#
# feature 'Dashboard' do
#
#   let(:super_user) { Fabricate :super }
#   let(:basic_user) { Fabricate :basic}
#   let(:coordinator_user) { Fabricate :coordinator }
#   let(:committer_user) { Fabricate :committer }
#
#   scenario 'Super User logs in and sees boring stuff' do
#
#     login_as super_user, scope: :user
#
#     visit root_path
#
#     expect(page).to have_text 'Welcome!'
#
#   end
#
#   scenario 'Basic User logs in and sees assigned Repo and Collection list' do
#
#     login_as basic_user, scope: :user
#
#     r = Fabricate(:repository)
#     c = Fabricate(:collection)
#
#     unassigned_r = Fabricate(:repository)
#     unassigned_c = Fabricate(:collection)
#
#     basic_user.repositories << r
#     basic_user.collections << c
#
#     visit root_path
#
#     expect(page).to have_link r.title
#     expect(page).to have_link c.display_title
#
#     expect(page).not_to have_link unassigned_r.title
#     expect(page).not_to have_link unassigned_c.display_title
#
#   end
#
#   scenario 'Coordinator User logs in and sees Users they manage' do
#
#     login_as coordinator_user, scope: :user
#
#     owned_user = Fabricate(:user, creator: coordinator_user)
#     foreign_user = Fabricate(:user)
#
#     visit root_path
#
#     expect(page).to have_link owned_user.email
#     expect(page).not_to have_link foreign_user.email
#
#   end
#
#   scenario 'Committer User logs in and sees pending Batches' do
#
#     login_as committer_user, scope: :user
#
#     b = Fabricate(:batch, user: committer_user)
#     foreign_b = Fabricate(:batch)
#
#     visit root_path
#
#     expect(page).to have_link b.name
#     expect(page).not_to have_link foreign_b.name
#   end
#
# end