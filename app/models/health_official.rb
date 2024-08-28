class HealthOfficial < ApplicationRecord
  belongs_to :state
  belongs_to :district, optional: true
  belongs_to :block, optional: true
  belongs_to :health_facility, optional: true
  belongs_to :organization_designation, class_name: 'OrganizationDesignation', foreign_key: 'designation_id'
  has_many :users

  private
  def set_nil_if_zero
    self.district_id = nil if district_id == 0
    self.block_id = nil if block_id == 0
    self.health_facility_id = nil if health_facility_id == 0
  end
end