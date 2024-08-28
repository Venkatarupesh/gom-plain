class ToiletType < ApplicationRecord
  has_many :dhs_metadata, :as => :seed_data
  has_many :family_toilet_statuses, dependent: :destroy
end
