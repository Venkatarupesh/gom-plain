module Api
  module V1
    class PersonalBirthDefectController < ApplicationController
      def create
        response = []
        ActiveRecord::Base.transaction do
          params['_json'].as_json.each do |record|
            service = CrudService.new('PersonalBirthDefect')
            response.push(service.create(record, :expires_at))
          end
        end
        json_response({ 'message': I18n.t('record_created/updated_successfully'), data: response, status: 'Success' }, :ok)
      end
      def destroy
        response = []
        ActiveRecord::Base.transaction do
          params['_json'].as_json.each do |record|
            service = CrudService.new('PersonalBirthDefect')
            response.push(service.delete(record))
          end
        end
        json_response({ message: I18n.t('record_deleted_successfully'), data: response, status: 'Success' }, :ok)
      end
    end
  end
end