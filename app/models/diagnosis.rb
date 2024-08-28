class Diagnosis < ApplicationRecord
  has_many :opd_diagnoses, dependent: :destroy
end
