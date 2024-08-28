class PersonalEducationStatus < ApplicationRecord
  belongs_to :person
  belongs_to :education_status
end
