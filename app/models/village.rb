class Village < ApplicationRecord
  before_create :create_timestamps
  before_update :update_timestamps
  before_validation(on: :create) do
    set_virtual_mapping
  end
  before_save :set_nil_if_zero
  before_update :set_virtual_mapping
  belongs_to :health_facility
  belongs_to :panchayat, optional: true
  belongs_to :sub_center, optional: true
  has_many :anganwadis
  has_many :hamlets
  has_many :health_workers
  has_many :families
  validate :sub_center_presence_if_not_null

  private
  def sub_center_presence_if_not_null
    if self.sub_center_id.present? && sub_center.nil?
      errors.add(:sub_center, "must exist")
    end
  end

  def set_virtual_mapping
    sub_center = SubCenter.find_by(health_facility_id: self.health_facility_id)
    if sub_center.present?
    self.sub_center_id = sub_center.id
    else
      self.sub_center_id = nil
    end
  end
  def create_timestamps
    self.general_updated_at = Time.now.to_i
    self.geo_updated_at = Time.now.to_i
    self.pf_updated_at = Time.now.to_i
  end
  def update_timestamps
    self.general_updated_at = Time.now.to_i if name_en_changed? || name_local_changed?
    self.geo_updated_at = Time.now.to_i if panchayat_id_changed?
    self.pf_updated_at = Time.now.to_i if health_facility_id_changed?
  end
  def set_nil_if_zero
    self.panchayat_id = nil if panchayat_id == 0
  end
end
