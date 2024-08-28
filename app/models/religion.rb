class Religion < ApplicationRecord
  has_many :dhs_metadata, :as => :seed_data
  has_many :people, dependent: :destroy
end
