require 'rails_helper'

RSpec.describe "repositories/index", type: :view do
  before(:each) do
    assign(:repositories, [
      Repository.create!(),
      Repository.create!()
    ])
  end

  it "renders a list of repositories" do
    render
  end
end
