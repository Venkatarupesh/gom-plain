class ChiefConcern < ApplicationRecord
  has_many :opd_metadata, :as => :seed_data
  has_many :opd_chief_concerns, dependent: :destroy
end
