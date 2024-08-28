module Api
  module V1
    class MedicineDispatchController < ApplicationController
      def create
        response = []
        ActiveRecord::Base.transaction do
          params['_json'].as_json.each do |record|
            service = CrudService.new('MedicineDispatch')
            response.push(service.create(record))
          end
        end
        json_response({ 'message': I18n.t('record_created/update_successfully'), data: response, status: 'Success' }, :ok)
      end
    end
  end
end
