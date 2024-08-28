class Occupation < ApplicationRecord
  has_many :dhs_metadata, :as => :seed_data
  has_many :personal_occupations, dependent: :destroy
end
