class PersonalOpd < ApplicationRecord
  belongs_to :person
  has_many :opd_nature_treatments, dependent: :destroy
  has_many :opd_treatments, dependent: :destroy
end
