class FamilyCategory < ApplicationRecord
  has_many :dhs_metadata, :as => :seed_data
  has_many :family_types, dependent: :destroy
end
