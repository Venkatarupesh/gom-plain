module Api
  module V1
    class OpdPrescriptionController < ApplicationController
      def create
        response = []
        ActiveRecord::Base.transaction do
          params['_json'].as_json.each do |record|
            service = CrudService.new('OpdPrescription')
            response.push(service.create(record))
            # result = service.create(record)
            # drug_code = Medicine.select(:drug_code).find_by(id: record['medicine_id']).drug_code
            # total_quantity = Inventory.find_by(drug_code: drug_code, health_facility_id: record['health_facility_id']).total_quantity
            # result = result.merge(drug_code: drug_code, total_quantity: total_quantity)
            # response.push(result)
          end
        end
        json_response({ 'message': I18n.t('record_created/update_successfully'), data: response, status: 'Success' }, :ok)
      end

      def destroy
        response = []
        ActiveRecord::Base.transaction do
          params['_json'].as_json.each do |record|
            service = CrudService.new('OpdPrescription')
            response.push(service.delete(record))
          end
        end
        json_response({ message: I18n.t('record_deleted_successfully'), data: response, status: 'Success' }, :ok)
      end
    end
  end
end
