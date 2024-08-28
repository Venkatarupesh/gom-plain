class NatureOfTreatment < ApplicationRecord
  has_many :dhs_metadata, :as => :seed_data
  has_many :ipd_nature_treatments, dependent: :destroy
  has_many :opd_nature_treatments, dependent: :destroy
end
