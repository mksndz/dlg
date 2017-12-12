require 'rails_helper'
require 'carrierwave/test/matchers'

describe ThumbnailUploader do
  let(:repository) { Fabricate :empty_repository }
  let(:uploader) { ThumbnailUploader.new(repository, :thumbnail) }
  before do
    ThumbnailUploader.enable_processing = true
    File.open(Rails.root.to_s + '/app/assets/images/no_thumb.png') do |f|
      uploader.store! f
    end
  end
  after do
    ThumbnailUploader.enable_processing = false
    uploader.remove!
  end
  it 'has the correct file name' do
    expect(uploader.file.path).to match /#{repository.slug}.png/
  end
end