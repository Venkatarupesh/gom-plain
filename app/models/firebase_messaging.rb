class FirebaseMessaging < ApplicationRecord
  belongs_to :health_worker
  validates :fcm_token, presence: true, uniqueness: true
end
