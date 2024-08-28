class IpdMedicalInstitution < ApplicationRecord
  has_many :dhs_metadata, :as => :seed_data
  has_many :ipd_hospitalization_frequencies, dependent: :destroy
  has_many :ipd_advices, dependent: :destroy
end