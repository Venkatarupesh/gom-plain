# frozen_string_literal: true

every 1.day, at: '12:00 pm' do
  runner 'MedicineStatsWorker.perform_async'
end
