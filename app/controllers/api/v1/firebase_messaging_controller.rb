module Api
  module V1
    class FirebaseMessagingController < ApplicationController
      def store_fcm_token
        health_worker = HealthWorker.find(@current_user.health_worker_id)

        firebase_messaging = FirebaseMessaging.find_or_initialize_by(health_worker_id: health_worker.id)
        firebase_messaging.update(fcm_token: params[:fcm_token])

        json_response({
                        message: I18n.t('fcm_token_stored_successfully'),
                        status: 'Success'
                      }, :ok)
      end

      def get_medicine_dispatch
        medicine_dispatches = MedicineDispatch.find(params[:id])
        medicine_warehouses = MedicineWarehouse.where(medicine_dispatch_id: medicine_dispatches.id)
        inventories = Inventory.where(health_facility_id: medicine_dispatches.health_facility_id)

        response = {
          medicine_dispatches: MedicineDispatchSerializer.new(medicine_dispatches).serializable_hash,
          medicine_warehouses: MedicineWarehouseSerializer.new(medicine_warehouses).serializable_hash,
          inventories: InventorySerializer.new(inventories).serializable_hash
        }

        json_response({ 'message': I18n.t('record_fetched_successfully'), data: response, status: 'Success' }, :ok)
      end
      def get_person
        person = Person.find_by(id: params[:id])
        opd_chief_concerns = person.opd_chief_concerns
        person_allergies = person.person_allergies
        person_medical_conditions = person.person_medical_conditions
        opd_vital_examinations = person.opd_vital_examinations
        opd_lab_tests = person.opd_lab_tests
        opd_visits = person.opd_visits
        person_habits = person.person_habits
        opd_prescriptions = person.opd_prescriptions
        opd_diagnoses = person.opd_diagnoses
        general_visits = person.general_visits
        prescription_refills = person.prescription_refills
        lab_test_visits = person.lab_test_visits

        response = {
          person: person,
          opd_chief_concerns: opd_chief_concerns,
          person_allergies: person_allergies,
          person_medical_conditions: person_medical_conditions,
          opd_vital_examinations: opd_vital_examinations,
          opd_lab_tests: opd_lab_tests,
          opd_visits: opd_visits,
          person_habits: person_habits,
          opd_prescriptions: opd_prescriptions,
          opd_diagnoses: opd_diagnoses,
          prescription_refills: prescription_refills,
          lab_test_visits: lab_test_visits,
          general_visits: general_visits,
          deleted_records: {
            person: Person.only_deleted.find_by(id: params[:id]),
            opd_chief_concerns: OpdChiefConcern.only_deleted,
            person_allergies: PersonAllergy.only_deleted,
            person_medical_conditions: PersonMedicalCondition.only_deleted,
            opd_vital_examinations: OpdVitalExamination.only_deleted,
            opd_lab_tests: OpdLabTest.only_deleted,
            opd_visits: OpdVisit.only_deleted,
            person_habits: PersonHabit.only_deleted,
            opd_prescriptions: OpdPrescription.only_deleted,
            opd_diagnoses: OpdDiagnosis.only_deleted,
            prescription_refills: PrescriptionRefill.only_deleted,
            lab_test_visits: LabTestVisit.only_deleted,
            general_visits: GeneralVisit.only_deleted
          }
        }

        json_response({ 'message': I18n.t('record_fetched_successfully'), data: response, status: 'Success' }, :ok)
      end


      def generate_notification_content(sender_name, sender_designation, patient_name, action)
        case action
        when 'MO to Staff Nurse'
          title = "#{sender_name} (#{sender_designation}) has sent #{patient_name}."
          body = 'Please complete the selected vitals.'
        when 'MO to Lab Technician'
          title = "#{sender_name} (#{sender_designation}) has sent #{patient_name}."
          body = 'Please conduct the selected Lab Tests.'
        when 'MO to Pharmacist'
          title = "#{sender_name} (#{sender_designation}) has sent #{patient_name}."
          body = 'Please dispense the selected medicine.'
        when 'Staff Nurse to MO'
          title = "#{sender_name} (#{sender_designation}) has completed the vitals of #{patient_name}."
          body = 'Please review.'
        when 'Lab Technician to MO'
          title = "#{sender_name} (#{sender_designation}) has conducted the tests of #{patient_name}."
          body = 'Please review.'
        when 'Pharmacist to MO'
          title = "#{sender_name} (#{sender_designation}) has dispensed medicine of #{patient_name}."
          body = 'Please review.'
        when 'Staff Nurse to Lab Technician'
          title = "#{sender_name} (#{sender_designation}) has sent #{patient_name}."
          body = 'Please conduct the selected Lab Tests.'
        when 'Lab Technician to Staff Nurse'
          title = "#{sender_name} (#{sender_designation}) has conducted the tests of #{patient_name}."
          body = 'Please review.'
        when 'Staff Nurse to Pharmacist'
          title = "#{sender_name} (#{sender_designation}) has sent #{patient_name}."
          body = 'Please dispense the selected medicine.'
        when 'Pharmacist to Staff Nurse'
          title = "#{sender_name} (#{sender_designation}) has dispensed medicine of #{patient_name}."
          body = 'Please review.'
        else
          title = 'Notification Title'
          body = 'Notification Body'
        end

        { title: title, body: body }
      end

      def push
        person_id = params[:person_id]
        person = Person.find(person_id)
        patient_name = "#{person.first_name} #{person.middle_name} #{person.last_name}"
        designation = params[:designation]
        sender_designation = @current_user.health_worker.designation
        sender_name = @current_user.health_worker.full_name
        health_workers = HealthWorker.where(health_facility_id: @current_user.health_worker.health_facility_id, designation: designation)
        health_workers.each do |health_worker|
          fcm_token = FirebaseMessaging.find_by(health_worker_id: health_worker.id)&.fcm_token
          receiver_designation = health_worker.designation
          action = "#{sender_designation} to #{receiver_designation}"
          notification_content = generate_notification_content(sender_name, sender_designation, patient_name, action)

          data = {
            person_id: person_id,
            sender_designation: @current_user.health_worker.designation_id.to_s,
            title: notification_content[:title],
            body: notification_content[:body]
          }
          fcm_service = FcmNotificationService.new(fcm_token, data)
          fcm_service.send_notification
        end
          json_response({
                          message: I18n.t('notification_sent_successfully'),
                          status: 'Success'
                        }, :ok)
      end
    end
  end
end
