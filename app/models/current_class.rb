class CurrentClass < ApplicationRecord
  has_many :dhs_metadata, :as => :seed_data
  has_many :personal_enrollment_educations, dependent: :destroy
end
