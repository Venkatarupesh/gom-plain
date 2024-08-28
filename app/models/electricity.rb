class Electricity < ApplicationRecord
  has_many :dhs_metadata, :as => :seed_data
  has_many :family_electricities, dependent: :destroy
end
