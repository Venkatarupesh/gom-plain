class School < ApplicationRecord
  has_many :dhs_metadata, :as => :seed_data
  belongs_to :school_type
  has_many :personal_school_details
end
