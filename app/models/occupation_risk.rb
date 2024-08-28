class OccupationRisk < ApplicationRecord
  has_many :dhs_metadata, :as => :seed_data
  has_many :personal_occupation_risks, dependent: :destroy
end
