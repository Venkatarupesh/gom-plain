class User < ApplicationRecord
  has_secure_password
  belongs_to :health_official, optional: true
  belongs_to :health_worker, optional: true
  has_many :user_attendances
  has_one :attendance, -> { where(punch_out_time: [0,nil]).order(created_at: :desc) }, class_name: 'UserAttendance', foreign_key: 'user_id'
  validate :validate_health_ids
  before_save :set_nil_if_zero
  private
  def validate_health_ids
    unless health_official_id.present? ^ health_worker_id.present?
      errors.add(:base, 'Either health_official_id or health_worker_id must be present, but not both.')
    end
  end
  def set_nil_if_zero
    self.health_official_id = nil if health_official_id == 0
    self.health_worker_id = nil if health_worker_id == 0
  end
end
