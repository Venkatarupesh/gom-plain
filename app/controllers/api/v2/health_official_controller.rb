module Api
  module V2
    class HealthOfficialController < ApplicationController
      skip_before_action :authenticate_request!

      def create
        health_official = HealthOfficial.new(hf_params)
        if health_official.save
          user = User.new(user_params)
          user.mobile = health_official.mobile
          user.is_approved = false
          user.health_official_id = health_official.id
          user.transaction_id = SecureRandom.uuid
          user.save

          json_response({
                          message: I18n.t('record_created_successfully'),
                          status: 'Success',
                          data: {
                            request_id: user.transaction_id,
                            approver_name: 'Contact Your Supervisor',
                            approver_designation: 'Supervisor',
                            approver_mobile: 'xxxxxxxxxx'
                          }
                        }, 200)
        else
          json_response({
                          message: health_official.errors.full_messages.join(', '),
                          status: 'Error'
                        }, 500)
        end
      end

      private

      def hf_params
        params.permit(:state_id, :district_id, :block_id, :health_facility_id, :designation_id,
                      :first_name, :middle_name, :last_name, :gender, :designation_id, :date_of_birth,
                      :mobile, :created_by, :updated_by, :created_at_app, :updated_at_app)
      end

      def user_params
        params.permit(:username, :password)
      end
    end
  end
end
