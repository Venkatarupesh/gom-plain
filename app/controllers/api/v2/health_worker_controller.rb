module Api
  module V2
    class HealthWorkerController < Api::ApiController
      before_action :villages, only: [:profile]
      skip_before_action :authenticate_request!, only: [:check_user_field, :create, :registration_status]

      def profile
        health_worker = HealthWorker.find(@current_user.health_worker_id)
        health_facility = HealthFacility.find(health_worker.health_facility_id)
        state = State.last
        district = District.find(health_facility.district_id)
        block = Block.find(health_facility.block_id)
        health_facilities = HealthFacility.where(facility_type: [1, 2, 3, 4, 5], block_id: block.id)
        health_facilities += HealthFacility.where(facility_type: 6, parent_hf_id: health_facilities.ids)
        health_workers = if [4, 5, 7, 8, 11].include?(health_worker.designation_id)
                           HealthWorker.where(health_facility_id: health_facilities.pluck(:id)).where.not(id: health_worker.id)
                         elsif [3, 6, 10].include?(health_worker.designation_id)
                           HealthWorker.where(health_facility_id: health_facilities.pluck(:id)).where.not(id: health_worker.id)
                                       .where(designation_id: [1, 2, 3, 6, 9, 10])
                         elsif [2, 9].include?(health_worker.designation_id)
                           HealthWorker.where(health_facility_id: health_facilities.pluck(:id)).where.not(id: health_worker.id)
                                       .where(designation_id: [1, 2, 9])
                         elsif health_worker.designation_id == 1
                           HealthWorker.where(health_facility_id: health_facilities.pluck(:id)).where.not(id: health_worker.id)
                                       .where(designation_id: 1)
                         end
        panchayats = Panchayat.where(block_id: block.id)
        rbac_level_one = RbacLevelOne.where("#{health_worker.designation_id} = designation")
        rbac_level_two = RbacLevelTwo.where(rbac_level_one_id: rbac_level_one)

        json_response({"message": I18n.t('record_fetched_successfully'),
                       data: {
                                           health_worker: HealthWorkerSerializer.new(health_worker).serializable_hash,
                                           health_workers: HealthWorkerSerializer.new(health_workers).serializable_hash,
                                           areas: AreaSerializer.new(areas).serializable_hash,
                                           panchayats: panchayats,
                                           villages: @villages,
                                           health_facilities: HealthFacilitySerializer.new(health_facilities).serializable_hash,
                                           block: block,
                                           district: district,
                                           state: state,
                                           rbac_level_ones: RbacLevelOneSerializer.new(rbac_level_one).serializable_hash,
                                           rbac_level_twos: RbacLevelTwoSerializer.new(rbac_level_two).serializable_hash
                                         }, status: "Success" }, 200)
      end

      def check_user_field
        user = if params[:field_type] == 'username'
                 User.find_by(username: params[:field_value])
               else
                 HealthWorker.find_by(params[:field_type] => params[:field_value])
               end
        if user.present?
          json_response({ message: I18n.t('fields_are_not_valid'), is_valid: false }, 422)
        else
          json_response({ message: I18n.t('fields_are_valid'), is_valid: true }, 200)
        end
      end

      def create
        health_worker = HealthWorker.new(hw_params)

        if health_worker.save
          user = User.new(user_params)
          user.mobile = health_worker.mobile
          user.is_approved = false
          user.health_worker_id = health_worker.id
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
                          message: health_worker.errors.full_messages.join(', '),
                          status: 'Error'
                        }, 500)
        end
      end

      def registration_status
        unless params[:request_id].present?
          json_response(
            { 'message': I18n.t('request_id_is_missing') }, 400
          )
          return
        end
        user = User.where(transaction_id: params[:request_id], is_approved: true)
        if user.present?
          json_response(
            { 'message': I18n.t('registration_approved_successfully'), is_approved: true }, 200)
        else
          json_response({ 'message': I18n.t('registration_not_approved'), is_approved: false }, 200)
        end
      end

      private

      def villages
        if [3, 4, 5].include? @current_user.health_worker.health_facility.facility_type_before_type_cast
          hf = @current_user.health_worker.health_facility.id
          temp = @current_user.health_worker.health_facility.phc.sub_centers.pluck(:health_facility_id)
          temp.push(hf)
          @villages = Village.where(health_facility_id: temp)
        elsif @current_user.health_worker.health_facility.facility_type_before_type_cast == 6
          @villages = if [1, 2, 9].include?(@current_user.health_worker.designation_id)
                        Village.where(id: @current_user.health_worker.village_id)
                      else
                        @current_user.health_worker.health_facility.sub_center.villages
                      end
        end
      end

      def areas
        if @current_user.health_worker.designation_id == 2
          Area.where(health_worker_id: @current_user.health_worker.id)
        else
          Area.where(village_id: @villages.ids)
        end
      end

      def hw_params
        params.permit(:health_facility_id, :village_id, :anganwadi_id, :phc_id, :sub_center_id,
                      :first_name, :middle_name, :last_name, :gender, :designation_id, :date_of_birth,
                      :mobile, :abha_id, :abha_address, :aadhaar_number, :employee_id, :employment_type,
                      :specialization_id, :hpr_id, :is_dashboard_user, :inactive_reason, :general_updated_at,
                      :geo_updated_at, :employment_updated_at, :created_by, :updated_by, :is_incharge,
                      :hpr_absence_reason, :approval_status, :approved_by)
      end

      def user_params
        params.permit(:username, :password)
      end
    end
  end
end