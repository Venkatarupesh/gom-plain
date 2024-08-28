module Api
  module V2
    class UserController < Api::ApiController
      skip_before_action :authenticate_request!, only: [:send_otp, :verify_otp, :resend_otp, :reset_password]

      def send_otp
        user = User.find_by(mobile: params[:mobile_number])
        if params[:is_registration] == 'true'
          if user
            json_response({ message: I18n.t('mobile_number_already_registered') }, 500)
          else
            otp_data = GenerateOtpHelper.verification_code
            Otp.create!(transaction_id: otp_data[:transaction_id], mobile: params[:mobile_number], otp: otp_data[:otp], valid_till: otp_data[:valid_till], hash_code: params[:hash], is_new_account: true)
            AwsSnsService.new.send_otp(params[:mobile_number].to_s, otp_data[:otp], params[:hash])
            json_response({ message: I18n.t('otp_sent_successfully'), is_new_account: true, transaction_id: otp_data[:transaction_id] }, 200)
          end
        elsif params[:is_registration] == 'false'
          if user
            otp_data = GenerateOtpHelper.verification_code
            Otp.create!(transaction_id: otp_data[:transaction_id], mobile: params[:mobile_number], otp: otp_data[:otp], valid_till: otp_data[:valid_till], hash_code: params[:hash], is_new_account: false)
            user.update(transaction_id: otp_data[:transaction_id])
            AwsSnsService.new.send_otp(user.mobile.to_s, otp_data[:otp], params[:hash])
            json_response({ message: I18n.t('otp_sent_successfully'), is_new_account: false, transaction_id: otp_data[:transaction_id] }, 200)
          else
            json_response({ message: I18n.t('user_not_found') }, 404)
          end
        else
          json_response({ message: I18n.t('something_went_wrong_please_try_again_later')}, 500)
        end
      rescue StandardError => e
        json_response({ message: e.message }, 500)
      end

      def resend_otp
        otp_record = Otp.find_by(transaction_id: params[:transaction_id])
        user = User.find_by(transaction_id: params[:transaction_id])
        return json_response({ message: I18n.t('otp_record_not_found') }, 404) unless otp_record
        if otp_record.valid_till.to_i < 1.minute.ago.to_i
          otp_data = GenerateOtpHelper.verification_code
          otp_record.update(otp: otp_data[:otp], valid_till: otp_data[:valid_till], transaction_id: otp_data[:transaction_id])
          user.update(transaction_id: otp_data[:transaction_id]) if user
          AwsSnsService.new.send_otp(otp_record.mobile.to_s, otp_data[:otp], otp_record.hash_code)
          json_response({ message: I18n.t('otp_resent_successfully'), transaction_id: otp_data[:transaction_id] }, 200)
        else
          json_response({ message: I18n.t('please_wait_for_otp_resend_time') }, 500)
        end
      rescue StandardError => e
        json_response({ message: e.message}, 500)
      end

      def verify_otp
        otp_record = Otp.find_by(transaction_id: params[:transaction_id])
        return json_response({ message: I18n.t('invalid_otp') }, 401) unless otp_record && otp_record.otp == params[:code].to_i
        if validate_otp(otp_record.valid_till)
          user = User.find_by(transaction_id: otp_record.transaction_id)
          if user
            otp_record.really_destroy! unless params[:is_reset_password] == 'true'
            json_response({ message: I18n.t('verify_otp_successfully'), username: user.username }, 200)
          elsif otp_record.is_new_account == true
            # otp_record.save!
            json_response({ message: I18n.t('verify_otp_successfully') }, 200)
          else
            return json_response({ message: I18n.t('user_not_found') }, 404)
          end
        else
          json_response({ message: I18n.t('otp_expired') }, 401)
        end
      rescue StandardError => e
        json_response({ message: e.message}, 500)
      end

      def validate_otp(valid_till)
        generated_at = Time.at(valid_till)
        expiry = generated_at + 5.minutes
        expiry >= Time.now
      end

      def reset_password
        otp_record = Otp.find_by(transaction_id: params[:transaction_id])
        user = User.find_by(transaction_id: otp_record&.transaction_id.to_s)
        if user && user.update(password: params[:password])
          otp_record.really_destroy!
          json_response({ message: I18n.t('password_reset_successfully') }, 200)
        else
          json_response({ message: I18n.t('failed_to_reset_password') }, 422)
        end
      end

    end
  end
end
