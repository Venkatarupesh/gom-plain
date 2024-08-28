module Response
  def json_response(object, status = :ok)
    unless @current_user.nil?
      unless ENV['ENCRYPTION_MODE'].present?
        object = Api::V1::EncryptionController.new.encrypt(object, @current_user.id)
      end
    end
    render json: object, status: status
  end
end
