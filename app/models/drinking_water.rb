class DrinkingWater < ApplicationRecord
  has_many :dhs_metadata, :as => :seed_data
  has_many :family_drinking_waters, dependent: :destroy
end
