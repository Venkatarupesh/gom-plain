module Api
  module V2
    class UserOrganizationController < ApplicationController
      skip_before_action :authenticate_request!

      def organizations
        organizations = Organization.where(organization_type_id: params[:organization_type_id])
        if organizations.present?
          json_response({ 'message': I18n.t('record_fetched_successfully'), data: { organizations: organizations.select(:id, :organization_type_id, :name, :name_local) }, status: 'Success' },
                        :ok)
        else
          json_response({ message: I18n.t('no_records'), status: 'Error' },
                        :unprocessable_entity)
        end
      end

      def organization_levels
        organization_levels = OrganizationLevel.where(id: OrganizationDesignation.where(organization_id: params[:organization_id]).pluck(:organization_level_id).uniq)
        if organization_levels.present?
          json_response({ 'message': I18n.t('record_fetched_successfully'), data: { organization_levels: organization_levels.select(:id, :name, :name_local) }, status: 'Success' },
                        :ok)
        else
          json_response({ message: I18n.t('no_records'), status: 'Error' },
                        :unprocessable_entity)
        end
      end

      def organization_designations
        organization_designations = OrganizationDesignation.where(organization_id: params[:organization_id], organization_level_id: params[:organization_level_id] )
        if organization_designations.present?
          json_response({ 'message': I18n.t('record_fetched_successfully'), data: { organization_designations: organization_designations.select(:id, :organization_id, :organization_level_id, :name, :name_local) }, status: 'Success' },
                        :ok)
        else
          json_response({ message: I18n.t('no_records'), status: 'Error' },
                        :unprocessable_entity)
        end
      end
    end
  end
end
