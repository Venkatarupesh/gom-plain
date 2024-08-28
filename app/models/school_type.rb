class SchoolType < ApplicationRecord
  has_many :dhs_metadata, :as => :seed_data
  has_many :personal_school_details, dependent: :destroy
  has_many :schools, dependent: :destroy
end
