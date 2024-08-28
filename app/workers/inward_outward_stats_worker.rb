class InwardOutwardStatsWorker
  include Sidekiq::Worker

  def perform(drug_code, health_facility_id, dispatch_type=nil, manually_added, available_quantity)
    current_date = Date.current
    inventory = Inventory.find_by(drug_code: drug_code, health_facility_id: health_facility_id)
    total_quantity = inventory.nil? ? 0 : inventory&.total_quantity
    medicine_dispatch = MedicineDispatch.find_by(health_facility_id: health_facility_id)

    # Use find_or_initialize_by to reduce database queries
    med_stat = MedicineStat.find_or_initialize_by(
      drug_code: drug_code,
      health_facility_id: health_facility_id,
      date: current_date
    )do |med_stat|
      med_stat.attributes = {
        id: BSON::ObjectId.new.to_s,
        opening: total_quantity,
        date: current_date,
        closing: total_quantity
      }
    end

    if manually_added
      med_stat.manual_inward_mode = 'Manual Inward'
      med_stat.manual_inward ||= 0
      med_stat.manual_inward += available_quantity
      med_stat.closing += available_quantity
    end
    # Use a case statement for better readability
    case dispatch_type
    when 'inward'
      med_stat.inward_mode = medicine_dispatch.warehouse_name
      med_stat.inward ||= 0
      med_stat.inward += available_quantity
      med_stat.closing += available_quantity
    when 'outward'
      med_stat.outward_mode = "Outward Medicine"
      med_stat.outward ||= 0
      med_stat.outward += available_quantity
      med_stat.closing -= available_quantity
    end


    med_stat.save!
  end
end
