module Api
  module V2
    class GeographyController < ApplicationController
      skip_before_action :authenticate_request!
      def state
        states = State.where(lgd_code: params[:lgd_code])
        districts = District.where(state_id: states.ids).select(:id, :state_id, :name_en, :name_local, :lgd_code)
        if states.present? && districts.present?
          json_response({ 'message': I18n.t('record_fetched_successfully'), data: { states: states.select(:id, :name_en, :name_local, :lgd_code), districts: districts }, status: 'Success' },
                        :ok)
        else
          json_response({ message: I18n.t('no_records'), status: 'Error' },
                        :unprocessable_entity)
        end
      end

      def district
        blocks = Block.where(district_id: params[:id]).select(:id, :district_id, :name_en, :name_local, :lgd_code)
        if blocks.present?
          json_response({ 'message': I18n.t('record_fetched_successfully'), data: { blocks: blocks }, status: 'Success' },
                        :ok)
        else
          json_response({ message: I18n.t('no_records'), status: 'Error' },
                        :unprocessable_entity)
        end
      end

      def block
        panchayats = Panchayat.where(block_id: params[:id]).select(:id, :block_id, :name_en, :name_local, :lgd_code)
        phcs = HealthFacility.where(block_id: params[:id], facility_type: [3, 4, 5]).select(:id, :district_id, :block_id, :name_en, :name_local)
        if panchayats.present? || phcs.present?
          json_response({ 'message': I18n.t('record_fetched_successfully'), data: { panchayats: panchayats, phcs: phcs }, status: 'Success' },
                        :ok)
        else
          json_response({ message: I18n.t('no_records'), status: 'Error' },
                        :unprocessable_entity)
        end
      end

      def phc
        sub_centers = HealthFacility.where(parent_hf_id: params[:id], facility_type: 6).select(:id, :district_id, :block_id, :name_en, :name_local)
        villages = Village.where(health_facility_id: params[:id], is_approved: true).select(:id, :health_facility_id, :name_en, :name_local, :lgd_code)
        if sub_centers.present? || villages.present?
          json_response({ 'message': I18n.t('record_fetched_successfully'), data: { sub_centers: sub_centers, villages: villages }, status: 'Success' },
                        :ok)
        else
          json_response({ message: I18n.t('no_records'), status: 'Error' },
                        :unprocessable_entity)
        end
      end

      def sub_center
        villages = Village.where(health_facility_id: params[:id], is_approved: true).select(:id, :health_facility_id, :name_en, :name_local, :lgd_code)
        if villages.present?
          json_response({ 'message': I18n.t('record_fetched_successfully'), data: { villages: villages }, status: 'Success' },
                        :ok)
        else
          json_response({ message: I18n.t('no_records'), status: 'Error' },
                        :unprocessable_entity)
        end
      end
    end
  end
end