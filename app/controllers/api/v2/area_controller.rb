module Api
  module V2
    class AreaController < ApplicationController
      before_action :set_area, only: %i[update destroy]

      def create
        @area = Area.new(area_params)
        if @area.save
          json_response({ 'message': I18n.t('record_created_successfully'), data: @area, status: 'Success' },
                        :ok)
        else
          json_response({ message: @area.errors.full_messages.join(', '), status: 'Error' },
                        :unprocessable_entity)
        end
      end

      def update
        if @area.update(area_params)
          json_response({ 'message': I18n.t('record_updated_successfully'), data: @area, status: 'Success' },
                        :ok)
        else
          json_response({ message: @area.errors.full_messages.join(', '), status: 'Error' },
                        :unprocessable_entity)
        end
      end

      def destroy
        @area.destroy
        json_response({ message: I18n.t('record_deleted_successfully'), data: @area, status: 'Success' }, :ok)
      end

      private

      # Use callbacks to share common setup or constraints between actions.
      def set_area
        @area = Area.find(params[:id])
      end

      # Only allow a list of trusted parameters through.
      def area_params
        params.permit(:village_id, :health_worker_id, :name_en, :name_local, :expected_population,
                      :expected_families, :expected_pregnant_women, :expected_children_0_1,
                      :expected_children_1_5, :is_dashboard_user, :inactive_reason, :general_updated_at,
                      :geo_updated_at, :target_updated_at, :created_by, :updated_by, :created_at_app, :updated_at_app)
      end
    end
  end
end
