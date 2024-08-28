class SubCenter < ApplicationRecord
  belongs_to :block
  belongs_to :phc
  belongs_to :health_facility
  has_many :villages
  has_many :health_workers
end
