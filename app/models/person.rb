class Person < ApplicationRecord
  include Vault::EncryptedModel
  vault_attribute :first_name
  vault_attribute :middle_name
  vault_attribute :last_name
  vault_attribute :gender
  vault_attribute :date_of_birth
  vault_attribute :mobile
  before_save :convert_fields_to_string
  after_save :create_abha
  belongs_to :health_facility
  belongs_to :village
  belongs_to :face_print
  belongs_to :family
  belongs_to :marital_status
  belongs_to :male_guardian, class_name: 'Person', foreign_key: 'male_guardian_id'
  belongs_to :female_guardian, class_name: 'Person', foreign_key: 'female_guardian_id'
  belongs_to :male_guardian_absence_reason, class_name: 'GuardianAbsenceReason', foreign_key: 'male_guardian_absence_reason_id'
  belongs_to :female_guardian_absence_reason, class_name: 'GuardianAbsenceReason', foreign_key: 'female_guardian_absence_reason_id'
  belongs_to :caste
  belongs_to :religion
  belongs_to :area
  has_many :personal_birth_defects, dependent: :destroy
  has_many :personal_diagnosed_diseases, dependent: :destroy
  has_many :personal_differently_ableds, dependent: :destroy
  has_many :personal_education_statuses, dependent: :destroy
  has_many :personal_enrollment_educations, dependent: :destroy
  has_many :personal_govt_schemes, dependent: :destroy
  has_many :personal_health_behaviours, dependent: :destroy
  has_many :personal_health_insurance_schemes, dependent: :destroy
  has_many :personal_ipds, dependent: :destroy
  has_many :personal_occupations, dependent: :destroy
  has_many :personal_occupation_risks, dependent: :destroy
  has_many :personal_opds, dependent: :destroy
  has_many :ipd_hospitalization_frequencies, dependent: :destroy
  has_many :ipd_nature_treatments, dependent: :destroy
  has_many :opd_nature_treatments, dependent: :destroy
  has_many :ipd_advices, dependent: :destroy
  has_many :opd_treatments, dependent: :destroy
  has_many :personal_school_details, dependent: :destroy
  has_many :opd_chief_concerns, dependent: :destroy
  has_many :person_allergies, dependent: :destroy
  has_many :person_medical_conditions, dependent: :destroy
  has_many :opd_vital_examinations, dependent: :destroy
  has_many :opd_lab_tests, dependent: :destroy
  has_many :opd_visits, dependent: :destroy
  has_many :person_habits, dependent: :destroy
  has_many :opd_prescriptions, dependent: :destroy
  has_many :opd_diagnoses, dependent: :destroy
  has_many :prescription_refills, dependent: :destroy
  has_many :lab_test_visits, dependent: :destroy
  has_many :general_visits, dependent: :destroy
  validates_presence_of :first_name, :gender, :date_of_birth
  validates :mobile, presence: true, length: { is: 10 }, numericality: { only_integer: true }, unless: Proc.new { |model| model.mobile.to_i.zero? }
  validates :aadhaar, presence: true, length: { is: 12 }, numericality: { only_integer: true }, unless: Proc.new { |model| model.aadhaar.to_i.zero? }
  validate -> { errors.clear if face_print_id <= '' }
  validate -> { errors.clear if family_id <= '' }
  validate -> { errors.clear if marital_status_id <= 0 }
  validate -> { errors.clear if male_guardian_id <= '' }
  validate -> { errors.clear if female_guardian_id <= '' }
  validate -> { errors.clear if male_guardian_absence_reason_id <= 0 }
  validate -> { errors.clear if female_guardian_absence_reason_id <= 0 }
  validate -> { errors.clear if caste_id <= 0 }
  validate -> { errors.clear if religion_id <= 0 }
  validate -> { errors.clear if area_id <= 0 }
  # TODO: Address pagination issues when querying this model.
  private

  def convert_fields_to_string
    self.date_of_birth = date_of_birth.to_s
    self.mobile = mobile.to_s
  end

  def create_abha
    if abha_status == 1
      AbhaIntegrationWorker.new.perform(id)
    end
  end
end

