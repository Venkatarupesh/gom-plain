class HouseStructure < ApplicationRecord
  has_many :dhs_metadata, :as => :seed_data
  has_many :family_house_structures, dependent: :destroy
end
