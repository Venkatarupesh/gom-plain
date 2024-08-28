class Area < ApplicationRecord
  belongs_to :village
  has_many :anganwadis
  has_many :houses
  has_many :people
  validate :check_area_limit, on: :create
  validate :hw_village_change, on: :update
  before_create :create_timestamps
  before_update :update_timestamps
  private
  def check_area_limit
    areas_count = Area.where(village_id: village_id).count
    if areas_count >= 5
      errors.add(:base, I18n.t('area_limit_reached'))
    end
  end
  def hw_village_change
    villages = Area.where(health_worker_id: health_worker_id).pluck(:village_id)
    if health_worker_id.present? && village_id.present? && villages.present? && Area.where(health_worker_id: health_worker_id).pluck(:village_id).exclude?(village_id)
      errors.add(:base, I18n.t('asha_cannot_change_village'))
    end
  end
  def create_timestamps
    self.general_updated_at = Time.now.to_i
    self.geo_updated_at = Time.now.to_i
    self.target_updated_at = Time.now.to_i
  end
  def update_timestamps
    self.general_updated_at = Time.now.to_i if name_en_changed? || name_local_changed?
    self.geo_updated_at = Time.now.to_i if village_id_changed?
    self.target_updated_at = Time.now.to_i if expected_population_changed? || expected_families_changed? || expected_families_changed? || expected_pregnant_women_changed?  || expected_children_0_1_changed? || expected_children_1_5_changed?
  end
end
