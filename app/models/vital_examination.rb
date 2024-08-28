class VitalExamination < ApplicationRecord
  has_many :opd_vital_examinations, dependent: :destroy
end
