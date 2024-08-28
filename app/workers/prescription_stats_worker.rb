class PrescriptionStatsWorker
  include Sidekiq::Worker

  def perform(drug_code, health_facility_id, quantity)
    current_date = Date.current

    med_stat = MedicineStat.find_or_create_by(
      drug_code: drug_code,
      health_facility_id: health_facility_id,
      date: current_date
    ) do |med_stat|
      inventory = Inventory.find_by(drug_code: drug_code, health_facility_id: health_facility_id)
      total_quantity = inventory.nil? ? 0 : inventory&.total_quantity
      med_stat.attributes = {
        id: BSON::ObjectId.new.to_s,
        opening: total_quantity,
        date: current_date,
        closing: total_quantity
      }
    end
    med_stat.prescribed ||= 0
    med_stat.prescribed += quantity
    med_stat.prescribed_mode = 'Prescribed'
    # Calculate closing
    med_stat.closing -= quantity

    med_stat.save!
  end
end
