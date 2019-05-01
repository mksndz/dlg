# frozen_string_literal: true

# Carrierwave class for handling Page JSON uploads
class PageJsonUploader < CarrierWave::Uploader::Base

  # Choose what kind of storage to use for this uploader:
  storage :file

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{model.id}/#{mounted_as}"
  end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  def default_url(*_args)
    ''
  end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  def extension_whitelist
    %w[json]
  end

  # Override the filename of the uploaded files
  def filename
    'data.json'
  end
end
