class GovtFamilyScheme < ApplicationRecord
  has_many :dhs_metadata, :as => :seed_data
  has_many :family_govt_schemes, dependent: :destroy
end
