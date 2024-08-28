class FamilyToiletStatusQue < ApplicationRecord
  belongs_to :family_toilet_status
  belongs_to :toilet_gender
  belongs_to :toilet_place_type
  validate -> { errors.clear if toilet_place_type_id <= 0 }
end
