require 'rails_helper'

RSpec.describe "batch_items/edit", type: :view do
  before(:each) do
    @batch_item = assign(:batch_item, BatchItem.create!())
  end

  it "renders the edit batch_item form" do
    render

    assert_select "form[action=?][method=?]", batch_item_path(@batch_item), "post" do
    end
  end
end
