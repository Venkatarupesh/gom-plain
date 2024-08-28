class FamilyHealthInsuranceScheme < ApplicationRecord
  belongs_to :family
  belongs_to :health_insurance_family_scheme
end
