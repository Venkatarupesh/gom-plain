class HealthBehaviour < ApplicationRecord
  has_many :dhs_metadata, :as => :seed_data
  has_many :personal_health_behaviours, dependent: :destroy
end
