require 'rails_helper'

RSpec.describe ItemsIngest::XmlToHashService, type: :model do

  it 'produces hashes' do
    job = Fabricate :batch_import
    service = ItemsXmlService.new(job.xml, ItemXmlHashProcessor)
    expect(service.hashes).to be_an Array
    expect(service.hashes.length).to eq 1
  end

end