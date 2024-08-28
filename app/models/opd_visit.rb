class OpdVisit < ApplicationRecord
  belongs_to :person
  belongs_to :village
  belongs_to :health_facility
  has_many :opd_chief_concern
  has_one :general_visit, as: :general_case
  has_many :opd_vital_examinations
  has_many :opd_lab_tests
  has_many :opd_prescriptions
  before_update :prevent_update_when_is_complete_is_2

  private

  def prevent_update_when_is_complete_is_2
    visit = OpdVisit.find(id)
    return true if visit.nil?

    if visit.is_complete == 2
      errors.add(:is_complete, "cannot update a completed visit")
      throw(:abort)
    end
  end
end
