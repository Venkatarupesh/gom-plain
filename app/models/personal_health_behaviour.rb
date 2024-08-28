class PersonalHealthBehaviour < ApplicationRecord
  belongs_to :person
  belongs_to :health_behaviour
  belongs_to :health_behaviour_frequency
  belongs_to :health_behaviour_duration
end
