class Disease < ApplicationRecord
  has_many :dhs_metadata, :as => :seed_data
  has_many :personal_diagnosed_diseases, dependent: :destroy
end
