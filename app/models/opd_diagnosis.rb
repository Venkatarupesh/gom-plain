class OpdDiagnosis < ApplicationRecord
  belongs_to :person
  belongs_to :health_facility
  belongs_to :village
  belongs_to :diagnosis
  belongs_to :opd_visit
end
