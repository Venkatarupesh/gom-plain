class PersonalSchoolDetail < ApplicationRecord
  belongs_to :person
  belongs_to :school_type
  belongs_to :school
end
