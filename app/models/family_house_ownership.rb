class FamilyHouseOwnership < ApplicationRecord
  belongs_to :family
  belongs_to :residence_type
  belongs_to :house_rent_duration
  validate -> { errors.clear if house_rent_duration_id <= 0 }
end
