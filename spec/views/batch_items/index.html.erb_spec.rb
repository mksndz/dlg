require 'rails_helper'

RSpec.describe "batch_items/index", type: :view do
  before(:each) do
    assign(:batch_items, [
      BatchItem.create!(),
      BatchItem.create!()
    ])
  end

  it "renders a list of batch_items" do
    render
  end
end
