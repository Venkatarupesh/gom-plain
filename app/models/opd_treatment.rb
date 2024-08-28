class OpdTreatment < ApplicationRecord
  belongs_to :person
  belongs_to :personal_opd
  belongs_to :opd_medical_institution
end