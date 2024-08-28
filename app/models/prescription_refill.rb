class PrescriptionRefill < ApplicationRecord
  belongs_to :person
  belongs_to :health_facility
  belongs_to :village
end
