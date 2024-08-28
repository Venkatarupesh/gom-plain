class PersonalOccupationRisk < ApplicationRecord
  belongs_to :person
  belongs_to :occupation_risk
end
