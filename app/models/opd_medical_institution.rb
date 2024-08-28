class OpdMedicalInstitution < ApplicationRecord
  has_many :dhs_metadata, :as => :seed_data
  has_many :opd_treatments, dependent: :destroy
end
