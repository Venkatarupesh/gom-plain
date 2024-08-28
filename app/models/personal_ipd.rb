class PersonalIpd < ApplicationRecord
  belongs_to :person
  has_many :ipd_nature_treatments, dependent: :destroy
  has_many :ipd_advices, dependent: :destroy
end
