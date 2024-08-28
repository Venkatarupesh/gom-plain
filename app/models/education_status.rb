class EducationStatus < ApplicationRecord
  has_many :dhs_metadata, :as => :seed_data
  has_many :personal_education_statuses, dependent: :destroy
end
