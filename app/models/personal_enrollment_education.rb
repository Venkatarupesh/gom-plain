class PersonalEnrollmentEducation < ApplicationRecord
  belongs_to :person
  belongs_to :current_class
end
