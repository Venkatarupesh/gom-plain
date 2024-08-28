module Api
  module V1
    class InventoryController < ApplicationController
      def create
        response = []
        ActiveRecord::Base.transaction do
          record =  params['inventory'].as_json
          service = CrudService.new('Inventory')
          response.push(service.create(record))
        end
        json_response({ 'message': I18n.t('record_created/update_successfully'), data: response, status: 'Success' }, :ok)
      end
    end
  end
end
