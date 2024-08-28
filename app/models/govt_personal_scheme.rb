class GovtPersonalScheme < ApplicationRecord
  has_many :dhs_metadata, :as => :seed_data
  has_many :personal_govt_schemes, dependent: :destroy
end
