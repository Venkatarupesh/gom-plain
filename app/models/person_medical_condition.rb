class PersonMedicalCondition < ApplicationRecord
  belongs_to :health_facility
  belongs_to :village
  belongs_to :person
  belongs_to :medical_condition
end
