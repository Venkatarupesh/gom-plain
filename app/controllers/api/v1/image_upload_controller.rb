module Api
  module V1
    class ImageUploadController < ApplicationController
      skip_before_action :authenticate_request!

      def upload
        uploader = ImageUploader.new
        if params[:file].present?
          # Handle file upload

          if uploader.store!(params[:file])
            AudioSample.create!(name: params[:name], file_name: params[:file_name], latitude: params[:latitude], longitude: params[:longitude])
          end
        elsif params[:image].present?
          # Handle image upload
          uploader.store!(params[:image])
          end
        json_response({ message: I18n.t('image_uploaded_successfully') }, 200)
      rescue StandardError => e
        json_response({ message: I18n.t('image_upload_failed') }, 400)
      end

      def delete_upload
        uploader = ImageUploader.new
        if AudioSample.find_by(file_name: params[:file_name]).destroy
          uploader.delete_file(params[:file_name]+".mp3")
         end
      end
    end
  end
end
