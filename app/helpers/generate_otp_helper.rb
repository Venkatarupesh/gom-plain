module GenerateOtpHelper
  class << self
    def verification_code
      if ENV["SECURE_OTP"].present? && ENV["SECURE_OTP"] == "true"
        { otp: (SecureRandom.random_number(9e5) + 1e5).to_i, valid_till: Time.now.to_i, transaction_id: SecureRandom.uuid }
      else
        { otp: 999999, valid_till: Time.now.to_i, transaction_id: SecureRandom.uuid }
      end
    end
  end
end
