class ApplicationController < ActionController::API
  include Response
  before_action :authenticate_request!, :set_locale, except: [:health_check]

  # System health check
  def health_check
    render json: { message: "API is up and running" }
  end

  # Validate user session and allow the request to continue
  def authenticate_request!
    unless session_id_in_token?
      json_response({ message: I18n.t('not_authenticated') }, 401)
      return
    end
    user_session = UserSession.find_by(session_id: auth_token.first['session_id'])
    @current_user = User.find_by(id: user_session&.user_id)
    # @current_user || json_response({ message: I18n.t('not_authenticated') }, 401)
    unless @current_user
      return json_response({ message: I18n.t('not_authenticated') }, 401)
    end
    unless ENV['ENCRYPTION_MODE'].present?
      request.path_parameters.delete(:controller)
      request.path_parameters.delete(:action)
      unless request.raw_post.empty?
        data = JSON.parse(request.raw_post)
        decrypted_data = Api::V1::EncryptionController.new.decrypt(data["data"], @current_user.id, data["iv"])
        if !request.path_parameters.empty?
          begin
            decrypted_data = (JSON.parse(decrypted_data).merge(request.path_parameters.transform_keys(&:to_s)))
          rescue Exception => e
            json_response({ message: "Decryption Error" }, 401)
          end
        else
          decrypted_data = JSON.parse(decrypted_data)
        end
        request.parameters.replace(decrypted_data)
      end
    end
    Sentry.set_user(id: @current_user&.id)
  rescue JWT::VerificationError, JWT::DecodeError
    json_response({ message: I18n.t('not_authenticated') }, 401)
  end

  # Split the authorization token header and store in a variable
  def http_token
    @http_token ||= (request.headers['Authorization'].split(' ').last if request.headers['Authorization'].present?)
  end

  # Decode the JWT
  def auth_token
    @auth_token ||= JsonWebToken.decode(http_token)
  end

  # Get session id from the token
  def session_id_in_token?
    if auth_token.instance_of?(Integer)
      false
    else
      http_token && auth_token && auth_token.first['session_id']
    end
  end

  def set_locale
    I18n.locale = extract_locale || I18n.default_locale
  end

  def extract_locale
    parsed_locale = request.parameters[:locale]
    return unless parsed_locale.present?

    I18n.available_locales.map(&:to_s).include?(parsed_locale) ? parsed_locale : nil

  end

end
