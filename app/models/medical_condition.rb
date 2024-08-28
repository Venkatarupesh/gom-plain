class MedicalCondition < ApplicationRecord
  has_many :opd_metadata, :as =>  :seed_data
  has_many :person_medical_conditions, dependent: :destroy
end
