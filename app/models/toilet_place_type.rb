class ToiletPlaceType < ApplicationRecord
  has_many :dhs_metadata, :as => :seed_data
  has_many :family_toilet_status_ques, dependent: :destroy
end
