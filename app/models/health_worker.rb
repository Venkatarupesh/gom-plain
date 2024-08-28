class HealthWorker < ApplicationRecord
  before_create :set_virtual_mapping, if: -> { [3, 4, 5, 6].include?(health_facility.facility_type_before_type_cast) }
  before_update :set_virtual_mapping, if: -> { [3, 4, 5, 6].include?(health_facility.facility_type_before_type_cast) }
  before_save :set_nil_if_zero
  belongs_to :health_facility
  belongs_to :village, optional: true
  belongs_to :organization_designation, class_name: 'OrganizationDesignation', foreign_key: 'designation_id'
  has_one :block, through: :health_facility
  has_one :district, through: :block
  has_one :state, through: :district
  belongs_to :phc, optional: true
  belongs_to :sub_center, optional: true
  belongs_to :specialization
  has_one :user
  has_one :firebase_messaging, dependent: :destroy
  validates :designation_id, presence: true
  before_create :create_timestamps
  before_update :update_timestamps
  validate -> { errors.clear if specialization_id <= 0 }

  private
  def set_virtual_mapping
    case health_facility.facility_type_before_type_cast
    when 6
      sub_center = SubCenter.find_by(health_facility_id: health_facility_id)
      self.sub_center_id = sub_center.id
      self.phc_id = sub_center.phc_id
    when 3, 4, 5
      phc = Phc.find_by(health_facility_id: health_facility_id)
      self.phc_id = phc.id
    end
  end
  def create_timestamps
    self.general_updated_at = Time.now.to_i
    self.geo_updated_at = Time.now.to_i
    self.employment_updated_at = Time.now.to_i
  end
  def update_timestamps
    self.general_updated_at = Time.now.to_i if first_name_changed? || middle_name_changed? || last_name_changed?
    self.geo_updated_at = Time.now.to_i if village_id_changed?
    self.employment_updated_at = Time.now.to_i if employee_id_changed? || employment_type_changed? || hpr_id_changed?
  end
  def set_nil_if_zero
    if [4, 5, 7, 8, 11].include?(designation_id)
      self.village_id = nil if village_id == 0
      self.anganwadi_id = nil if anganwadi_id == 0
      self.sub_center_id = nil if sub_center_id == 0
    elsif [3, 6, 10].include?(designation_id)
      self.village_id = nil if village_id == 0
      self.anganwadi_id = nil if anganwadi_id == 0
    elsif [2, 9].include?(designation_id)
      self.anganwadi_id = nil if anganwadi_id == 0
    end
  end
end
