class Specialization < ApplicationRecord
  has_many :dhs_metadata, :as => :seed_data
  has_many :health_workers, dependent: :destroy
end
