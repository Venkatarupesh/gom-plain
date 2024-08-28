class District < ApplicationRecord
  has_many :blocks
  has_many :health_facilities
end
