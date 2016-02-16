require 'rails_helper'

RSpec.describe "batch_items/show", type: :view do
  before(:each) do
    @batch_item = assign(:batch_item, BatchItem.create!())
  end

  it "renders attributes in <p>" do
    render
  end
end
