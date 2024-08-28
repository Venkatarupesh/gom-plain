class Phc < ApplicationRecord
  belongs_to :health_facility
  belongs_to :block
  has_many :sub_centers
  has_many :villages, through: :sub_centers
  has_many :health_workers
end
