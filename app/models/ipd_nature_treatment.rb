class IpdNatureTreatment < ApplicationRecord
  belongs_to :person
  belongs_to :personal_ipd
  belongs_to :nature_of_treatment
end