class Block < ApplicationRecord
  belongs_to :district
  has_many :panchayats
  has_many :villages, through: :panchayats
  has_many :health_facilities
  has_many :phcs
  has_many :sub_centers
end
