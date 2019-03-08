require 'rails_helper'

RSpec.describe ItemXmlHashProcessor, type: :model do
  let(:service) do
    ItemXmlService.new(
      xml: Fabricate(:batch_import).xml,
      results_service: nil,
      hash_processor: ItemXmlHashProcessor
    ) # TODO: inject results service
  end

  it 'produces hashes' do
    expect(service.hashes).to be_an Array
  end
end