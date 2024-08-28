# frozen_string_literal: true

class MedicineStatsWorker
  include Sidekiq::Worker

  def perform
    # Get the current date
    current_date = Date.current

    Inventory.all.each do |inventory|
      # Find the existing MedicineStat record for the specific day
      medicine_stat = MedicineStat.find_by(
        drug_code: inventory.drug_code,
        health_facility_id: inventory.health_facility_id,
        created_at: current_date.beginning_of_day..current_date.end_of_day
      )

      if medicine_stat
        # Update the existing record
        medicine_stat.update!(opening: inventory.total_quantity)
      else
        # Create a new MedicineStat record
        MedicineStat.create!(
          drug_code: inventory.drug_code,
          health_facility_id: inventory.health_facility_id,
          id: BSON::ObjectId.new.to_s,
          opening: inventory.total_quantity,
          created_at: current_date,
          inward_mode: inventory.health_facility.name_en,
          outward_mode: inventory.health_facility.name_en
        )
      end
    end
  end

end
