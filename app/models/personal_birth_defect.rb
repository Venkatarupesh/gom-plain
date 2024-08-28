class PersonalBirthDefect < ApplicationRecord
  belongs_to :person
  belongs_to :birth_defect
end
