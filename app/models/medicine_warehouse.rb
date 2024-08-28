class MedicineWarehouse < ApplicationRecord
  belongs_to :health_facility
  belongs_to :medicine_dispatch, optional: true

  before_save :update_inventory

  private

  def update_inventory
    # return true unless medicine_dispatch.present?
    if (!medicine_dispatch.present? || medicine_dispatch.dispatch_type == 'inward') && receiver_ack == 1
      credit_acc = Inventory.find_by(health_facility_id: health_facility_id, drug_code: drug_code)
      InwardOutwardStatsWorker.new.perform(drug_code, health_facility_id, medicine_dispatch&.dispatch_type, !medicine_dispatch.present?, quantity_in_units)
      if credit_acc.present?
        credit_acc.total_quantity += quantity_in_units
        credit_acc.save!
      else
        Inventory.create!(id: BSON::ObjectId.new.to_s,health_facility_id: health_facility_id, drug_code: drug_code, total_quantity: quantity_in_units, min_quantity: min_quantity)
      end
    elsif medicine_dispatch.dispatch_type == 'outward'
      if receiver_ack == 0
      debit_acc = Inventory.find_by(health_facility_id: medicine_dispatch.sender_facility_id, drug_code: drug_code)
      InwardOutwardStatsWorker.new.perform(drug_code, medicine_dispatch.sender_facility_id, medicine_dispatch&.dispatch_type, !medicine_dispatch.present?, quantity_in_units)
      debit_acc.total_quantity -= quantity_in_units
      debit_acc.save!
      elsif receiver_ack == 1
      credit_acc = Inventory.find_by(health_facility_id: health_facility_id, drug_code: drug_code)
      InwardOutwardStatsWorker.new.perform(drug_code,health_facility_id, "inward", !medicine_dispatch.present?, quantity_in_units)
      if credit_acc.present?
        credit_acc.total_quantity += quantity_in_units
        credit_acc.save!
      else
        Inventory.create!(id: BSON::ObjectId.new.to_s,health_facility_id: health_facility_id, drug_code: drug_code, total_quantity: quantity_in_units, min_quantity: min_quantity)
      end
      elsif receiver_ack == 2
        credit_acc = Inventory.find_by(health_facility_id: medicine_dispatch.sender_facility_id, drug_code: drug_code)
        credit_acc.total_quantity += quantity_in_units
        credit_acc.save!
      end
    end
  end

end
