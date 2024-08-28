# frozen_string_literal: true

module Api
  module V1
    class MedicineStatsController < ApplicationController
      def index
        medical_stats = MedicineStat.where(health_facility_id: @current_user.health_worker.health_facility_id,
                                           date: params[:start_date]..params[:end_date])

        medicine_stats = if params[:drug_code].present? && params[:drug_code] != '0'
                           medical_stats.where(drug_code: params[:drug_code])
                         else
                           medical_stats
                         end

        json_response(
          { 'message': I18n.t('record_fetched_successfully'),
            data: MedicineStatSerializer.new(medicine_stats).serializable_hash }, 200
        )
      end
    end
  end
end