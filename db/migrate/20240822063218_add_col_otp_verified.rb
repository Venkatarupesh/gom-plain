class AddColOtpVerified < ActiveRecord::Migration[7.0]
  def change
    add_column :otps, :otp_verified, :integer
  end
end
