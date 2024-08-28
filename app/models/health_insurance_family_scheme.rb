class HealthInsuranceFamilyScheme < ApplicationRecord
  has_many :dhs_metadata, :as => :seed_data
  has_many :family_health_insurance_schemes, dependent: :destroy
end
