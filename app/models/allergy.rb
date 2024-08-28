class Allergy < ApplicationRecord
  has_many :person_allergies, dependent: :destroy
end
