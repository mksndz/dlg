require 'rails_helper'

RSpec.describe ItemXmlService, type: :model do
  let(:service) { ItemXmlService.new }

  it 'produces hashes' do
    service.xml = Fabricate(:batch_import).xml
    expect(service.hashes).to be_an Array
  end
end