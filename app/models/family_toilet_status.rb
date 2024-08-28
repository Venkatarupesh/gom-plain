class FamilyToiletStatus < ApplicationRecord
  belongs_to :family
  belongs_to :toilet_type
end
