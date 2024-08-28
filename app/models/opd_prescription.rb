class OpdPrescription < ApplicationRecord
  before_save do
    PrescriptionStatsWorker.new.perform(medicine.drug_code, health_facility_id, quantity)
  end
  
  before_save :update_inventory

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
  
  belongs_to :person
  belongs_to :health_facility
  belongs_to :village
  belongs_to :medicine
  belongs_to :opd_visit, optional: true
  belongs_to :general_visit, optional: true
  private
  def update_inventory
    if medicine_given == 1 && audited != 1
      debit_acc = Inventory.find_by(health_facility_id: health_facility_id, drug_code: medicine.drug_code)
      if debit_acc.nil?
        debit_acc = Inventory.create!(id: BSON::ObjectId.new.to_s, drug_code: medicine.drug_code, health_facility_id: health_facility_id, total_quantity: 0, min_quantity: 0)
      end
      debit_acc.total_quantity -= quantity
      debit_acc.save!
      self.audited = 1
    end
  end

end
