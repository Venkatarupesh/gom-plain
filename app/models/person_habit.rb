class PersonHabit < ApplicationRecord
  belongs_to :health_facility
  belongs_to :village
  belongs_to :person
end
