class OpdLabTest < ApplicationRecord
  before_validation(on: :create) do
    if self.general_visit_id.nil? && !opd_visit_id.nil?
      general_visit = GeneralVisit.find_or_create_by(
        person_id: person_id,
        general_case_type: 'OpdVisit',
        general_case_id: opd_visit_id
      ) do |visit|
        visit.id = BSON::ObjectId.new.to_s
        visit.health_facility_id = health_facility_id
        visit.village_id = village_id
        visit.created_at_app = created_at_app
        visit.updated_at_app = updated_at_app
        visit.created_by = created_by
        visit.updated_by = updated_by
      end
      self.general_visit_id = general_visit.id if general_visit.save!
    end
  end
  belongs_to :health_facility
  belongs_to :village
  belongs_to :person
  belongs_to :lab_test
  belongs_to :opd_visit, optional: true
  belongs_to :general_visit, optional: true
end
