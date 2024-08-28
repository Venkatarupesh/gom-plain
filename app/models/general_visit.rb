class GeneralVisit < ApplicationRecord
  belongs_to :general_case, polymorphic: true
  belongs_to :person
  belongs_to :village
  belongs_to :health_facility
  has_many :opd_vital_examinations, dependent: :destroy
  has_many :opd_lab_tests, dependent: :destroy
  has_many :opd_prescriptions, dependent: :destroy
end
