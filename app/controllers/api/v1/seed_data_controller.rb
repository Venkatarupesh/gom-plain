# frozen_string_literal: true
module Api
  module V1
    class SeedDataController < Api::ApiController
      def master
        chief_concerns = ChiefConcern.all
        medical_conditions = MedicalCondition.all
        allergies = Allergy.all
        vital_examinations = VitalExamination.all
        lab_tests = LabTest.all
        diagnoses = Diagnosis.all
        medicines = Medicine.all
        outreach_activities = OutreachActivity.all
        outreach_activity_types = OutreachActivityType.all
        outreach_meeting_types = OutreachMeetingType.all

        json_response({'message': I18n.t('record_fetched_successfully'),
                       data: {
                         sync_time: Time.now.to_i,
                         chief_concerns: chief_concerns,
                         medical_conditions: medical_conditions,
                         allergies: allergies,
                         vital_examinations: vital_examinations,
                         lab_tests: lab_tests,
                         diagnoses: diagnoses,
                         medicines: medicines,
                         outreach_activities: outreach_activities,
                         outreach_activity_types: outreach_activity_types,
                         outreach_meeting_types: outreach_meeting_types
                       }, status: 'Success'}, 200)
      end

      def opd
        opd_metadata = OpdMetadatum.all
        json_response({'message': I18n.t('record_fetched_successfully'),
                       data: {
                         sync_time: Time.now.to_i,
                         opd_metadata: opd_metadata,
                       }, status: 'Success'}, 200)
      end
    end
  end
end


