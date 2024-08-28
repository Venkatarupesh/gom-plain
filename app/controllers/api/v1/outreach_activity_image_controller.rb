class Api::V1::OutreachActivityImageController < Api::ApiController
  skip_before_action :authenticate_request!

  def upload
    image = OutreachActivityImageUploader.new
    image.store!(params[:image])
    json_response({ message: I18n.t('image_uploaded_successfully') }, 200)
  rescue StandardError => e
    json_response({ message: I18n.t('image_upload_failed') }, 400)
  end
end
