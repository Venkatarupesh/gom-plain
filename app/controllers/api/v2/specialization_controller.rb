module Api
  module V2
    class SpecializationController < ApplicationController
      skip_before_action :authenticate_request!

      def get
        specializations = Specialization.all
        if specializations.present?
          json_response({ 'message': I18n.t('record_fetched_successfully'), data: { specializations: specializations.select(:id, :name, :name_local, :order) }, status: 'Success' },
                        :ok)
        else
          json_response({ message: I18n.t('no_records'), status: 'Error' },
                        :unprocessable_entity)
        end
      end
    end
  end
end
