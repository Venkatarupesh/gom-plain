class Organization < ApplicationRecord
  belongs_to :organization_type
  has_many :organization_designations
end
