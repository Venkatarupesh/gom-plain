class PersonalHealthInsuranceScheme < ApplicationRecord
  belongs_to :person
  belongs_to :health_insurance_personal_scheme
end
