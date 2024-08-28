class HealthFacility < ApplicationRecord
  belongs_to :district
  belongs_to :block
  has_many :villages

  after_commit :manage_virtual_mappings, on: :create
  after_commit :manage_virtual_mappings, on: :update

  has_one :phc
  has_one :sub_center
  has_many :health_workers
  has_many :medicine_dispatches
  has_many :medicine_warehouses
  has_many :inventories
  has_many :medicine_stats
  has_many :families
  before_update :update_timestamps
  before_create :create_timestamps
  enum facility_type: {
    'District Hospital': 1, 'Talluk General Hospital': 2, 'UPHC': 3,
    'CHC': 4, 'PHC': 5, 'Sub Center': 6
  }

  private

  def manage_virtual_mappings
    if [3, 4, 5, 6].include?(facility_type_before_type_cast)
      if facility_type_before_type_cast == 6
        sub_center = SubCenter.find_or_initialize_by(health_facility_id: id)
        sub_center.update(block_id: block_id, phc_id: Phc.find_by(health_facility_id: parent_hf_id).id)
        sub_center.destroy unless sub_center.persisted?
      else
        phc = Phc.find_or_initialize_by(health_facility_id: id)
        phc.update(block_id: block_id)
        phc.destroy unless phc.persisted?
      end
    end
  end
  def create_timestamps
    self.general_updated_at = Time.now.to_i
    self.geo_updated_at = Time.now.to_i
    self.pf_updated_at = Time.now.to_i
    self.ids_updated_at = Time.now.to_i
    self.aam_updated_at = Time.now.to_i
  end
  def update_timestamps
    self.general_updated_at = Time.now.to_i if name_en_changed? || name_local_changed?
    self.geo_updated_at = Time.now.to_i if district_id_changed? || block_id_changed?
    self.pf_updated_at = Time.now.to_i if parent_hf_id_changed?
    self.ids_updated_at = Time.now.to_i if nhm_hf_id_changed? || nha_hfr_id_changed? || nin_code_changed? || pcts_code_changed?
    self.aam_updated_at = Time.now.to_i if clinical_hf_changed? || aam_changed?
  end
end



#
# HealthFacility.where(facility_type:[3,4,5]).each do |hf|
#  Phc.create!(health_facility_id:hf.id,taluka_id:hf.taluka_id)
#  end
#
#
# HealthFacility.where(facility_type:6).each do |hf|
#   SubCenter.create!(health_facility_id:hf.id,taluka_id:hf.taluka_id,phc_id: Phc.find_by(health_facility_id: hf.parent_hf_id).id)
# end
