class LabTest < ApplicationRecord
  has_many :opd_lab_tests, dependent: :destroy
end
