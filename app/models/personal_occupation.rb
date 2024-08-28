class PersonalOccupation < ApplicationRecord
  belongs_to :person
  belongs_to :occupation
end
