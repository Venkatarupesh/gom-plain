class IpdHospitalizationFrequency < ApplicationRecord
  belongs_to :person
  belongs_to :personal_ipd
  belongs_to :ipd_medical_institution
  validates :ipd_medical_institution_id, exclusion: { in: [888], message: "cannot be 'None'" }
end
