require 'rails_helper'

RSpec.describe "batch_items/new", type: :view do
  before(:each) do
    assign(:batch_item, BatchItem.new())
  end

  it "renders new batch_item form" do
    render

    assert_select "form[action=?][method=?]", batch_items_path, "post" do
    end
  end
end
