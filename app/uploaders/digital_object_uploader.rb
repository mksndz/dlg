# Carrierwave class for handling digital object uploads
class DigitalObjectUploader < CarrierWave::Uploader::Base
  # Include RMagick or MiniMagick support:
  # include CarrierWave::RMagick
  # include CarrierWave::MiniMagick

  # Choose what kind of storage to use for this uploader:
  storage :file

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    'digital_objects/' +
      model.item.repository.slug + '/' +
      model.item.collection.slug + '/' +
      model.item.slug
  end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  # def default_url(*args)
  #   ActionController::Base.helpers.asset_path 'dlg_default_image.png'
  # end

  def extension_whitelist
    %w[jpg jpeg gif png pdf jp2 jpeg2 tiff]
  end

  # Override the filename of the uploaded files
  def filename
    if original_filename
      "#{model.item.record_id}-#{model.number.rjust 4, '0'}.#{file.extension}"
    end
  end
end
