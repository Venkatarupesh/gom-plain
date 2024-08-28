class House < ApplicationRecord
  belongs_to :health_facility
  belongs_to :village
  belongs_to :area
  has_many :families, dependent: :destroy
  has_many :people, through: :families
  validate -> { errors.clear if area_id <= 0 }
  before_update :update_people_area_id, if: :will_save_change_to_area_id?

  private
  def update_people_area_id
    people.update_all(area_id: area_id)
  end
end