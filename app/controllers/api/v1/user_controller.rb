module Api
  module V1
    class UserController < Api::ApiController

      def multiple_punch_in_out
        if params[:_json].each { |punch_in_out_params| punch_in_out(punch_in_out_params) }.all?
          json_response({ message: I18n.t('attendance_marked_successfully'), status: "Success" }, 201)
        else
          json_response({ message: I18n.t('something_went_wrong_please_try_again_later'), status: "Error" }, :unprocessable_entity)
        end
      end

      def single_punch_in_out
        if punch_in_out(params)
          json_response({ message: I18n.t('attendance_marked_successfully'), status: "Success" }, 201)
        else
          json_response({ message: I18n.t('something_went_wrong_please_try_again_later'), status: "Error" }, :unprocessable_entity)
        end
      end

      def punch_in_out(params)
        if (params[:punch_out_time]).zero?
          mark_attendance
        end
        user_attendance = UserAttendance.find_or_initialize_by(id: params[:id])
        user_attendance.assign_attributes(health_worker_id: @current_user.health_worker_id,
                                          user_id: @current_user.id,
                                          punch_in_latitude: params[:punch_in_latitude],
                                          punch_in_longitude: params[:punch_in_longitude],
                                          punch_in_time: params[:punch_in_time],
                                          out_of_facility: params[:out_of_facility],
                                          health_facility_id: HealthWorker.find(@current_user.health_worker_id).health_facility_id,
                                          punch_out_time: params[:punch_out_time],
                                          punch_out_latitude: params[:punch_out_latitude],
                                          punch_out_longitude: params[:punch_out_longitude]
        )
        user_attendance.save!
      end

      def mark_attendance
        old_attendance = @current_user.attendance
        unless old_attendance.nil?
          punch_in_time = old_attendance.punch_in_time
          punch_in_datetime = DateTime.strptime(punch_in_time.to_s, '%s')
          current_date = DateTime.now.to_date
          old_attendance.punch_out_time = (punch_in_datetime.to_date == current_date) ? (Time.now.utc).to_i : (Time.at(punch_in_time).in_time_zone('Asia/Kolkata').end_of_day.utc).to_i
        end
        old_attendance&.save!
        true
      end
    end
  end
end
