require 'rails_helper'

class FakeController < ActionController::Base
  include MultipleActionable
end

RSpec.describe ItemsController, type: :controller do


  let(:super_user) {
    Fabricate(:super)
  }

  before(:each) {
    sign_in super_user
    allow(FakeController).to receive(:controller_name) { 'Item' }
  }

  it 'deletes entities when commit param contain delete' do
    item1 = Fabricate(:item)
    item2 = Fabricate(:item)
    expect {
      post :multiple_action, {commit: 'delete', ids: [item1.id, item2.id]}
    }.to change(Item, :count).by(-2)
  end

  it 'returns when commit param contain xml' do
    item1 = Fabricate(:item)
    item2 = Fabricate(:item)
    post :multiple_action, {commit: 'xml', ids: [item1.id, item2.id]}
    expect(response.body).to include item2.slug
  end

end