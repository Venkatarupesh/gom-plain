class OrganizationDesignation < ApplicationRecord
  belongs_to :organization
  belongs_to :organization_level
  has_many :health_officials
  has_many :health_workers
end
