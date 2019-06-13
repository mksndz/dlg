# frozen_string_literal: true

# Facilitates upload to the DPLA's AWS S3 bucket for the DLG
class DplaS3Service

  # @param [String] folder
  def initialize(folder)
    configure_aws
    @bucket = Rails.application.secrets.dpla_s3_dlg_bucket
    @folder = folder
    @notifier = NotifierService.new
  end

  # @param [File] file
  def upload(file)
    return false unless file.is_a? File

    name = File.join @folder, file.basename
    upload = @s3.bucket(@bucket).object(name).upload_file(file)
    msg = if upload
            "DPLA S3 Service: `#{name}` was uploaded to #{@bucket}`."
          else
            "DPLA S3 Service: upload of `#{name}` to `#{@bucket}` failed!"
          end
    @notifier.notify msg
    upload
  end

  private

  def configure_aws
    s3_client = Aws::S3::Client.new(
      access_key_id: Rails.application.secrets.dpla_s3_access_key_id,
      secret_access_key: Rails.application.secrets.dpla_s3_secret_access_key
    )
    @s3 = Aws::S3::Resource.new(client: s3_client)
  end
end