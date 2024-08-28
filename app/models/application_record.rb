class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class
  acts_as_paranoid
  scope :locked, -> { where(:status =>0) }
  scope :active, -> { where(:status =>1) }
  scope :inactive, -> { where(:status =>2) }
  before_save :update_expires_at

  private

  def update_expires_at
    return unless new_record? || changed?

    if self.class.name.in?(%w[FamilyType FamilyHouseOwnership])
      self.expires_at = Time.now.to_i + 180.days.to_i
    elsif self.class.name.in?(%w[FamilyHouseStructure FamilyToiletStatus FamilyDrinkingWater FamilyElectricity
                                 FamilyTransportVehicle FamilyCookingFuel FamilyNfsa FamilyGovtScheme FamilyHealthInsuranceScheme
                                 PersonalEnrollmentEducation PersonalEducationStatus PersonalSchoolDetail PersonalOccupation
                                 PersonalOccupationRisk PersonalGovtScheme PersonalHealthInsuranceScheme PersonalBirthDefect
                                 PersonalDiagnosedDisease PersonalDifferentlyAbled PersonalHealthBehaviour PersonalIpd PersonalOpd])
      self.expires_at = Time.now.to_i + 365.days.to_i
    end
  end
end
