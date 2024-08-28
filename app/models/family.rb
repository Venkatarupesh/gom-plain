class Family < ApplicationRecord
  belongs_to :health_facility
  belongs_to :village
  belongs_to :house
  # belongs_to :hamlet
  has_many :people, dependent: :destroy
  has_many :family_cooking_fuels, dependent: :destroy
  has_many :family_drinking_waters, dependent: :destroy
  has_many :family_electricities, dependent: :destroy
  has_many :family_govt_schemes, dependent: :destroy
  has_many :family_health_insurance_schemes, dependent: :destroy
  has_one :family_type, dependent: :destroy
  has_one :family_house_ownership, dependent: :destroy
  has_many :family_house_structures, dependent: :destroy
  has_many :family_nfsas, dependent: :destroy
  has_many :family_toilet_statuses, dependent: :destroy
  has_many :family_transport_vehicles, dependent: :destroy
end