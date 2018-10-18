require 'rails_helper'

describe MetaGeocoder do
  it 'returns coordinates' do
    expect(MetaGeocoder.lookup('Jimmy Carter Boulevard (Gwinnett County, Ga.)')).not_to be_nil
  end
  it 'returns nil if lookup fails for any reason' do
    expect(MetaGeocoder.lookup('98yr984wurfio')).to be_nil
  end
end