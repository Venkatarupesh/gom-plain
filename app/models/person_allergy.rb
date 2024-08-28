class PersonAllergy < ApplicationRecord
  belongs_to :health_facility
  belongs_to :village
  belongs_to :person
  belongs_to :allergy
end
