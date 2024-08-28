class CookingFuel < ApplicationRecord
  has_many :dhs_metadata, :as => :seed_data
  has_many :family_cooking_fuels, dependent: :destroy
end
