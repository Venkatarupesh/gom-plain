module Api
  module V1
    class HealthFacilityController < Api::ApiController

      def update_lat_long
        hf = HealthFacility.find(params[:id]).update(latitude: params[:latitude], longitude: params[:longitude])
        json_response({
                        message: I18n.t('health_facility_location_updated'),
                        data: hf,
                        status: 'Success'
                      }, :ok)
      end
    end
  end
end
