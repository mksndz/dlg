# frozen_string_literal: true

require 'digest/md5'

# Facilitates upload to the DPLA's AWS S3 bucket for the DLG
class DplaS3Service

  # @param [String] folder
  def initialize(folder)
    configure_aws
    @bucket = Rails.application.secrets.dpla_s3_dlg_bucket
    @folder = folder
    @notifier = NotificationService.new
  end

  # @param [String] path
  def upload(path)
    return false unless File.exist? path

    name = File.join @folder, File.basename(path)
    file_md5 = Digest::MD5.file(path).base64digest
    upload = @s3.bucket(@bucket)
                .object(name)
                .upload_file(path, content_md5: file_md5)
    unless upload
      @notifier.notify "DPLA S3 Service: upload of `#{name}` to `#{@bucket}` failed!"
    end
    upload
  end

  private

  def configure_aws
    s3_client = Aws::S3::Client.new(
      region: 'us-east-1',
      access_key_id: Rails.application.secrets.dpla_s3_access_key_id,
      secret_access_key: Rails.application.secrets.dpla_s3_secret_access_key
    )
    @s3 = Aws::S3::Resource.new(client: s3_client)
  end
end