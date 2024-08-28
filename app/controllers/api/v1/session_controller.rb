# frozen_string_literal: true

module Api
  module V1
    class SessionController < Api::ApiController
      skip_before_action :authenticate_request!, only: [:create]

      def create
        unless ENV['ENCRYPTION_MODE'].present?
          data = JSON.parse(request.raw_post)
          decrypted_data =  Api::V1::EncryptionController.new.decrypt(data["data"],data["request_id"],data["iv"])
          request.parameters.replace(JSON.parse(decrypted_data).merge(request.query_parameters))
        end
        user = User.find_by(username: params[:username])
        if user&.authenticate(params[:password])
          if user.is_approved == true
            # Successful authentication
            unless ENV['ENCRYPTION_MODE'].present?
              login_user(user, data["request_id"])
            else
              login_user(user,nil)
            end
          elsif user.is_approved == false
            json_response({ message: I18n.t('user_not_approved'), status: 'Error' }, :unauthorized)
          end
        else
          json_response({ message: I18n.t('invalid_username_or_password'), status: 'Error' }, :unauthorized)
        end
      end

      def destroy(user_id = nil)
        current_user_session = if user_id
                                 UserSession.find_by(user_id: user_id)
                               else
                                 UserSession.find_by(user_id: @current_user.id)
                               end
        if current_user_session
          current_user_session.update(logout_time: Time.now.to_i)
          current_user_session.really_destroy!
          # puts "logout:#{current_user_session.logout_time} and status:#{current_user_session.status}"
        end
        return if user_id
        json_response({ message: I18n.t('logged_out_successfully'), status: 'Success' }, :ok)
      end

      private

      def login_user(user, request_id)
        unless ENV['ENCRYPTION_MODE'].present?
          destroy(user.id)
        end
        session = UserSession.new
        session.session_id = Digest::MD5.new.hexdigest(Time.now.to_i.to_s)
        session.login_time = Time.now.to_i
        session.user_id = user.id
        session.save!
        unless ENV['ENCRYPTION_MODE'].present?
          shared_key = Vault.logical.read("secret/data/#{request_id}")
          shared_key = shared_key&.data&.dig(:data, :shared_key)
          vault_path = "secret/data/#{user.id}"
          Vault.logical.write(vault_path, data: { shared_key: shared_key})
          Vault.logical.delete("secret/data/#{request_id}")
        end
        object = {
          message: I18n.t('logged_in_successfully'),
          status: 'Success',
          data: { auth_token: JsonWebToken.encode({ session_id: session.session_id }) }
        }
        unless ENV['ENCRYPTION_MODE'].present?
          object = Api::V1::EncryptionController.new.encrypt(object, user.id)
        end
        render json: object, status: 200
      end
    end
  end
end
