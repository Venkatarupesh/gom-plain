class OpdNatureTreatment < ApplicationRecord
  belongs_to :person
  belongs_to :personal_opd
  belongs_to :nature_of_treatment
end