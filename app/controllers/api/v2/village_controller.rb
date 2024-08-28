module Api
  module V2
    class VillageController < ApplicationController
      before_action :set_village, only: %i[update]
      skip_before_action :authenticate_request!, only: [:check_village_field]

      def create
        village = Village.new(village_params)
        village.is_approved = false

        if village.save
          approver_details = { approver_name: '', approver_designation: '', approver_mobile: '' }

          user = HealthWorker.find_by(id: @current_user.health_worker.id)
          case user.designation_id
          when 1
            approver_designation = 2
          when 2, 9
            approver_designation = 3
          when 6, 3, 10
            approver_designation = 8
          end

          if approver_designation.present?
            approver = HealthWorker.find_by(health_facility_id: village.health_facility_id, designation_id: approver_designation)
            designation = if params[:locale] == 'en'
                            OrganizationDesignation.where(id: approver.designation_id).pluck(:name)
                          else
                            OrganizationDesignation.where(id: approver.designation_id).pluck(:name_local)
                          end
            if approver
              approver_details = {
                approver_name: "#{approver.first_name} #{approver.middle_name} #{approver.last_name}",
                approver_designation: designation&.first,
                approver_mobile: approver.mobile
              }
            end
          end

          json_response({
                          message: I18n.t('record_created_successfully'),
                          status: 'Success',
                          data: {
                            request_id: @current_user.transaction_id,
                            approver_name: approver_details[:approver_name],
                            approver_designation: approver_details[:approver_designation],
                            approver_mobile: approver_details[:approver_mobile].to_s
                          }
                        }, 200)
        else
          json_response({
                          message: village.errors.full_messages.join(', '),
                          status: 'Error'
                        }, 500)
        end
      end
      def update
        if @village.update(village_params)
          json_response({ 'message': I18n.t('record_created/updated_successfully'), data: @village, status: 'Success' },
                        :ok)
        else
          json_response({ message: I18n.t('something_went_wrong_please_try_again_later'), status: "Error" },
                        :unprocessable_entity)
        end
      end

      def check_village_field
        village = Village.find_by(params[:field_type] => params[:field_value])
        if village.present?
          json_response({ message: I18n.t('fields_are_not_valid'), is_valid: false }, 422)
        else
          json_response({ message: I18n.t('fields_are_valid'), is_valid: true }, 200)
        end
      end

      private
      # Use callbacks to share common setup or constraints between actions.
      def set_village
        @village = Village.find(params[:id])
      end

      # Only allow a list of trusted parameters through.
      def village_params
        params.permit(:panchayat_id, :health_facility_id, :sub_center_id, :name_en, :name_local, :lgd_code,
                      :census_code_2011, :is_dashboard_user, :inactive_reason, :general_updated_at,
                      :geo_updated_at, :pf_updated_at, :created_by, :updated_by, :created_at_app, :updated_at_app,
                      :lgd_absent_reason, :census_code_absent_reason)
      end
    end
  end
end