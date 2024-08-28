class MedicineDispatch < ApplicationRecord
  after_save :notify
  # before_save :update_inventory
  belongs_to :health_facility
  has_many :medicine_warehouses, dependent: :destroy
  enum dispatch_type: { inward: 1, outward: 2 }

  private
  def update_inventory
      if accept_dispatch_before_type_cast == 1 && medicine_dispatch.dispatch_type == 'outward'
        medicine_warehouses.each do|mw|
        debit_acc =  Inventory.find_by(health_facility_id: sender_facility_id, drug_code: mw.drug_code)
        debit_acc.total_quantity -= mw.quantity_in_units
        debit_acc.save!

        credit_acc = Inventory.find_by(health_facility_id: health_facility_id, drug_code: mw.drug_code)
          if credit_acc.present?
            credit_acc.total_quantity += mw.quantity_in_units
            credit_acc.save!
          else
            Inventory.create!(id: BSON::ObjectId.new.to_s,health_facility_id: health_facility_id, drug_code: mw.drug_code, total_quantity: mw.quantity_in_units, min_quantity: mw.min_quantity)
          end
        end
      end
  end

  def notify
    return unless (dispatch_type == 'outward' && accept_dispatch == 2 && !HealthWorker.find_by(health_facility_id: health_facility_id, designation: "CHO").nil?)

    health_worker = HealthWorker.find_by(health_facility_id: health_facility_id, designation: "CHO")
    fcm_token = FirebaseMessaging.find_by(health_worker_id: health_worker.id)&.fcm_token

    return unless fcm_token

    data = {
      down_sync: true,
      title: "Medicine Dispatched",
      body: "please process it when you receive"
    }
    fcm_service = FcmNotificationService.new(fcm_token, data)
    fcm_service.send_notification
  end
end
