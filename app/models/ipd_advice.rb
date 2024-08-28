class IpdAdvice < ApplicationRecord
  belongs_to :person
  belongs_to :personal_ipd
  belongs_to :ipd_medical_institution
end