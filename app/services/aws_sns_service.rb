# frozen_string_literal: true

require 'aws-sdk-sns'

class AwsSnsService
  def initialize
    @client = Aws::SNS::Client.new(region: ENV['AWS_REGION'], access_key_id: ENV['AWS_ACCESS_KEY_ID'], secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'])
  end

  def send_otp(mobile_number, otp, hash)
    message = "#{otp} is your OTP for mobile number verification on GOM app. It is valid till #{(DateTime.now + 5.minutes).strftime("%d-%b-%Y %H:%M:%S %p")}. #{hash}"
    @client.publish({ phone_number: "+91"+mobile_number, message: message })
  end
end
