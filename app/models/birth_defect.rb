class BirthDefect < ApplicationRecord
  has_many :dhs_metadata, :as => :seed_data
  has_many :personal_birth_defects, dependent: :destroy
end
