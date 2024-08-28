class Disability < ApplicationRecord
  has_many :dhs_metadata, :as => :seed_data
  has_many :personal_differently_ableds, dependent: :destroy
end
