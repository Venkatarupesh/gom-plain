class OpdChiefConcern < ApplicationRecord
  belongs_to :health_facility
  belongs_to :village
  belongs_to :person
  belongs_to :opd_visit
  belongs_to :chief_concern
end
