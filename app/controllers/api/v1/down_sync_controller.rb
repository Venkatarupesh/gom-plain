module Api
  module V1
    class DownSyncController < ApplicationController
      before_action :villages
      def sync
        # Get the page parameter from the request, default to 1 if not provided or invalid
        page = params[:page].to_i.positive? ? params[:page].to_i : 1

        # Check if it's a full restore or point in time restore based on the last_down_sync_time parameter
        if params[:last_down_sync_time].to_i.zero?
          full_restore(page)
        else
          point_in_time_restore
        end
      end

      #noinspection RubyUnusedLocalVariable
      def full_restore(page = 1)
        # Set the fixed per_page value to 10
        per_page = 10

        # Calculate the offset to skip the appropriate number of records for the current page
        offset = (page - 1) * per_page
        families = Family.where(village_id: @villages).limit(per_page).offset(offset)
        # Fetch people records based on the calculated offset and limit the result to per_page records


        # Fetch the total number of people records
        total_people_count = Person.where(village_id: @villages).count

        # Calculate the total number of pages needed for pagination
        total_pages = (total_people_count / per_page.to_f).ceil

        # Check if there are more pages
        has_next_page = page < total_pages
        person = Person.where(family_id: families.ids)
        opd_visits = OpdVisit.where(person_id: person.pluck(:id))
                       .order(person_id: :asc, created_at_app: :desc)
                             .group_by(&:person_id)
                             .transform_values { |visits| visits.first(2) }
        opd_visits = opd_visits.values.flatten
        prescription_refills = PrescriptionRefill.where(person_id: person.pluck(:id))
                                                 .order(person_id: :asc, created_at_app: :desc)
                                                 .group_by(&:person_id)
                                                 .transform_values { |visits| visits.first(2) }
        prescription_refills = prescription_refills.values.flatten
        lab_test_visits = LabTestVisit.where(person_id: person.pluck(:id))
                                      .order(person_id: :asc, created_at_app: :desc)
                                      .group_by(&:person_id)
                                      .transform_values { |visits| visits.first(2) }
        lab_test_visits = lab_test_visits.values.flatten

        general_visits = GeneralVisit.where(general_case_id: [opd_visits.pluck(:id)+ prescription_refills.pluck(:id)+ lab_test_visits.pluck(:id)])

        opd_chief_concerns = OpdChiefConcern.where(opd_visit_id:opd_visits.pluck(:id))
        person_allergies = PersonAllergy.where(person_id:person.ids)
        person_medical_conditions = PersonMedicalCondition.where(person_id:person.ids)
        opd_vital_examinations = OpdVitalExamination.where(general_visit_id: general_visits.ids)
        opd_lab_tests = OpdLabTest.where(general_visit_id: general_visits.ids)


        person_habits = PersonHabit.where(person_id:person.ids)
        opd_prescriptions = OpdPrescription.where(general_visit_id: general_visits.ids)
        opd_diagnoses = OpdDiagnosis.where(opd_visit_id: opd_visits.pluck(:id))
        health_facility = HealthFacility.find(@current_user.health_worker.health_facility_id)
        taluka = Taluka.find(health_facility.taluka_id)
        health_facilities = HealthFacility.where(facility_type: [1, 2, 3, 4, 5], taluka_id: taluka.id)
        health_facilities += HealthFacility.where(facility_type: 6, parent_hf_id: health_facilities.ids)
        health_workers = HealthWorker.where(health_facility_id: health_facilities.pluck(:id)).where.not(id: @current_user.health_worker.id)
        # health_worker = HealthWorker.where(id: @current_user.health_worker_id)
        health_worker_with_current_user = HealthWorker.where(health_facility_id: health_facilities.pluck(:id)).ids
        wellness_activities = WellnessActivity.where(health_worker_id: health_worker_with_current_user)
        trainings = Training.where(health_worker_id: health_worker_with_current_user)
        meetings = Meeting.where(health_worker_id: health_worker_with_current_user)
        medicine_dispatches = MedicineDispatch.where(health_facility_id: @current_user.health_worker.health_facility_id)
        temp = MedicineDispatch.where(sender_facility_id: @current_user.health_worker.health_facility_id)
        medicine_dispatches += temp
        medicine_warehouses = MedicineWarehouse.where(health_facility_id: @current_user.health_worker.health_facility_id) + MedicineWarehouse.where(medicine_dispatch_id: temp.pluck(:id))
        medicine_warehouses = medicine_warehouses.uniq
        inventories = Inventory.where(health_facility_id: @current_user.health_worker.health_facility_id)
        face_prints = FacePrint.where(id:person.pluck(:face_print_id))


        response = {
          sync_time: Time.now.to_i,
          families: FamilySerializer.new(families).serializable_hash,
          people: PersonSerializer.new(person).serializable_hash,
          opd_chief_concerns: OpdChiefConcernSerializer.new(opd_chief_concerns).serializable_hash,
          person_allergies: PersonAllergySerializer.new(person_allergies).serializable_hash,
          person_medical_conditions: PersonMedicalConditionSerializer.new(person_medical_conditions),
          opd_vital_examinations: OpdVitalExaminationSerializer.new(opd_vital_examinations).serializable_hash,
          opd_lab_tests: OpdLabTestSerializer.new(opd_lab_tests).serializable_hash,
          opd_visits: OpdVisitSerializer.new(opd_visits).serializable_hash,
          general_visits: GeneralVisitSerializer.new(general_visits).serializable_hash,
          person_habits: PersonHabitSerializer.new(person_habits).serializable_hash,
          opd_prescriptions: OpdPrescriptionSerializer.new(opd_prescriptions).serializable_hash,
          opd_diagnoses: OpdDiagnosisSerializer.new(opd_diagnoses).serializable_hash,
          wellness_activities: WellnessActivitySerializer.new(wellness_activities).serializable_hash,
          trainings: TrainingSerializer.new(trainings).serializable_hash,
          meetings: MeetingSerializer.new(meetings).serializable_hash,
          medicine_dispatches: MedicineDispatchSerializer.new(medicine_dispatches).serializable_hash,
          medicine_warehouses: MedicineWarehouseSerializer.new(medicine_warehouses).serializable_hash,
          inventories: InventorySerializer.new(inventories).serializable_hash,
          prescription_refills: PrescriptionRefillSerializer.new(prescription_refills).serializable_hash,
          lab_test_visits: lab_test_visits,
          face_prints: FacePrintSerializer.new(face_prints).serializable_hash,
          pagination: {
            current_page: page,
            total_pages: total_pages,
            total_entries: total_people_count,
            has_next_page: has_next_page
          }
        }

        json_response({ 'message': I18n.t('record_fetched_successfully'), data: response, status: 'Success' }, :ok)
      end

      def point_in_time_restore
        person = Person.where(village_id: @villages).active
        person_ids = person.ids
        opd_chief_concerns = down_sync_fun('opd_chief_concerns', person_ids)
        person_allergies = down_sync_fun('person_allergies', person_ids)
        person_medical_conditions = down_sync_fun('person_medical_conditions', person_ids)
        opd_vital_examinations = down_sync_fun('opd_vital_examinations', person_ids)
        opd_lab_tests = down_sync_fun('opd_lab_tests', person_ids)
        opd_visits = down_sync_fun('opd_visits', person_ids)
        general_visits = down_sync_fun('general_visits', person_ids)
        person_habits = down_sync_fun('person_habits', person_ids)
        opd_prescriptions = down_sync_fun('opd_prescriptions', person_ids)
        opd_diagnoses = down_sync_fun('opd_diagnoses', person_ids)
        person = person&.where(updated_at: Time.zone.at(params[:last_down_sync_time].to_i)..DateTime.now.in_time_zone)
        health_facility = HealthFacility.find(@current_user.health_worker.health_facility_id)
        taluka = Taluka.find(health_facility.taluka_id)
        health_facilities = HealthFacility.where(facility_type: [1, 2, 3, 4, 5], taluka_id: taluka.id)
        health_facilities += HealthFacility.where(facility_type: 6, parent_hf_id: health_facilities.ids)
        health_workers = HealthWorker.where(health_facility_id: health_facilities.pluck(:id),
                                            updated_at: Time.zone.at(params[:last_down_sync_time].to_i)..DateTime.now.in_time_zone).where.not(id: @current_user.health_worker.id).active
        health_worker_with_current_user = HealthWorker.where(health_facility_id: health_facilities.pluck(:id),
                                                             updated_at: Time.zone.at(params[:last_down_sync_time].to_i)..DateTime.now.in_time_zone, status:1).ids
        wellness_activities = down_sync_play('wellness_activities', health_worker_with_current_user)
        trainings = down_sync_play('trainings', health_worker_with_current_user)
        meetings = down_sync_play('meetings', health_worker_with_current_user)
        medicine_dispatches = MedicineDispatch.where(
          health_facility_id: @current_user.health_worker.health_facility_id, updated_at: Time.zone.at(params[:last_down_sync_time].to_i)..DateTime.now.in_time_zone)
        temp = MedicineDispatch.where(sender_facility_id: @current_user.health_worker.health_facility_id,
                                      updated_at: Time.zone.at(params[:last_down_sync_time].to_i)..DateTime.now.in_time_zone)
        medicine_dispatches += temp
        medicine_warehouses = MedicineWarehouse.where(
          health_facility_id: @current_user.health_worker.health_facility_id, updated_at: Time.zone.at(params[:last_down_sync_time].to_i)..DateTime.now.in_time_zone) + MedicineWarehouse.where(
          medicine_dispatch_id: temp.pluck(:id), updated_at: Time.zone.at(params[:last_down_sync_time].to_i)..DateTime.now.in_time_zone)
        medicine_warehouses=medicine_warehouses.uniq
        inventories = Inventory.where(health_facility_id: @current_user.health_worker.health_facility_id,
                                      updated_at: Time.zone.at(params[:last_down_sync_time].to_i)..DateTime.now.in_time_zone)
        prescription_refills = down_sync_fun('prescription_refills', person_ids)
        lab_test_visits = down_sync_fun('lab_test_visits', person_ids)
        face_print_ids = Person.where(id: person_ids).pluck(:face_print_id)
        face_prints = FacePrint.where(id: face_print_ids,
                        updated_at: Time.zone.at(params[:last_down_sync_time].to_i)..DateTime.now.in_time_zone)
        response = {
          sync_time: Time.now.to_i,
          people: PersonSerializer.new(person).serializable_hash,
          opd_chief_concerns: OpdChiefConcernSerializer.new(opd_chief_concerns).serializable_hash,
          person_allergies: PersonAllergySerializer.new(person_allergies).serializable_hash,
          person_medical_conditions: PersonMedicalConditionSerializer.new(person_medical_conditions),
          opd_vital_examinations: OpdVitalExaminationSerializer.new(opd_vital_examinations).serializable_hash,
          opd_lab_tests: OpdLabTestSerializer.new(opd_lab_tests).serializable_hash,
          opd_visits: OpdVisitSerializer.new(opd_visits).serializable_hash,
          general_visits: GeneralVisitSerializer.new(general_visits).serializable_hash,
          person_habits: PersonHabitSerializer.new(person_habits).serializable_hash,
          opd_prescriptions: OpdPrescriptionSerializer.new(opd_prescriptions).serializable_hash,
          opd_diagnoses: OpdDiagnosisSerializer.new(opd_diagnoses).serializable_hash,
          wellness_activities: WellnessActivitySerializer.new(wellness_activities).serializable_hash,
          trainings: TrainingSerializer.new(trainings).serializable_hash,
          meetings: MeetingSerializer.new(meetings).serializable_hash,
          medicine_dispatches: MedicineDispatchSerializer.new(medicine_dispatches).serializable_hash,
          medicine_warehouses: MedicineWarehouseSerializer.new(medicine_warehouses).serializable_hash,
          inventories: InventorySerializer.new(inventories).serializable_hash,
          prescription_refills: PrescriptionRefillSerializer.new(prescription_refills).serializable_hash,
          lab_test_visits: LabTestVisitSerializer.new(lab_test_visits).serializable_hash,
          face_prints: FacePrintSerializer.new(face_prints).serializable_hash,
          deleted_records: {
            people: PersonSerializer.new(Person.where(village_id: @villages,
                                                      deleted_at: Time.zone.at(params[:last_down_sync_time].to_i)..DateTime.now.in_time_zone)
            ).serializable_hash,
            opd_chief_concerns: OpdChiefConcernSerializer.new(deleted_down_sync_fun('opd_chief_concerns',
                                                                                    person_ids)).serializable_hash,
            person_allergies: PersonAllergySerializer.new(deleted_down_sync_fun('person_allergies',
                                                                                person_ids)).serializable_hash,
            person_medical_conditions: PersonMedicalConditionSerializer.new(deleted_down_sync_fun(
                                                                              'person_medical_conditions', person_ids)),
            opd_vital_examinations: OpdVitalExaminationSerializer.new(deleted_down_sync_fun('opd_vital_examinations',
                                                                                            person_ids)).serializable_hash,
            opd_lab_tests: OpdLabTestSerializer.new(deleted_down_sync_fun('opd_lab_tests',
                                                                          person_ids)).serializable_hash,
            opd_visits: OpdVisitSerializer.new(OpdVisitSerializer.new(deleted_down_sync_fun('opd_visits',
                                                                                            person_ids)).serializable_hash).serializable_hash,
            person_habits: PersonHabitSerializer.new(deleted_down_sync_fun('person_habits',
                                                                           person_ids)).serializable_hash,
            opd_prescriptions: OpdPrescriptionSerializer.new(deleted_down_sync_fun('opd_prescriptions',
                                                                                   person_ids)).serializable_hash,
            opd_diagnoses: OpdDiagnosisSerializer.new( deleted_down_sync_fun('opd_diagnoses',
                                                                             person_ids)).serializable_hash
          }
        }

        json_response({ 'message': I18n.t('record_fetched_successfully'), data: response, status: 'Success' }, :ok)
      end

      private
      def villages
        if [3, 4, 5].include? @current_user.health_worker.health_facility.facility_type_before_type_cast
          hf = @current_user.health_worker.health_facility.id
          temp = @current_user.health_worker.health_facility.phc.sub_centers.pluck(:health_facility_id)
          temp.push(hf)
          @villages = Village.where(health_facility_id: temp)
        elsif @current_user.health_worker.health_facility.facility_type_before_type_cast == 6
          @villages = @current_user.health_worker.health_facility.sub_center.villages
        end
      end
      def down_sync_fun(model, person_ids)
        model.classify.constantize.where(person_id: person_ids,
                                         updated_at: Time.zone.at(params[:last_down_sync_time].to_i)..DateTime.now.in_time_zone).active
      end
      def deleted_down_sync_fun(model, person_ids)
        model.classify.constantize.with_deleted.where(person_id: person_ids,
                                                      deleted_at: Time.zone.at(params[:last_down_sync_time].to_i)..DateTime.now.in_time_zone).active
      end

      def down_sync_play(model, health_worker_ids)
        model.classify.constantize.where(health_worker_id: health_worker_ids,
                                         updated_at: Time.zone.at(params[:last_down_sync_time].to_i)..DateTime.now.in_time_zone).active
      end
    end
  end
end

