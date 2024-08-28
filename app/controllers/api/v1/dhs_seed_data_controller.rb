# frozen_string_literal: true
module Api
  module V1
    class DhsSeedDataController < Api::ApiController
      def master
        languages = Language.all.active
        family_categories = FamilyCategory.all
        residence_types = ResidenceType.all
        house_structures = HouseStructure.all
        house_rent_durations = HouseRentDuration.all
        school_types = SchoolType.all
        schools = School.all
        toilet_types = ToiletType.all
        toilet_genders = ToiletGender.all
        toilet_place_types = ToiletPlaceType.all
        govt_family_schemes = GovtFamilyScheme.all
        health_insurance_family_schemes = HealthInsuranceFamilyScheme.all
        castes = Caste.all
        religions = Religion.all
        marital_statuses = MaritalStatus.all
        guardian_absence_reasons = GuardianAbsenceReason.all
        govt_personal_schemes = GovtPersonalScheme.all
        health_insurance_personal_schemes = HealthInsurancePersonalScheme.all
        current_classes = CurrentClass.all
        education_statuses = EducationStatus.all
        diseases = Disease.all
        birth_defects = BirthDefect.all
        health_behaviours = HealthBehaviour.all
        health_behaviour_frequencies = HealthBehaviourFrequency.all
        health_behaviour_durations = HealthBehaviourDuration.all
        disabilities = Disability.all
        cooking_fuels = CookingFuel.all
        electricities = Electricity.all
        transport_vehicles = TransportVehicle.all
        drinking_waters = DrinkingWater.all
        occupations = Occupation.all
        occupation_risks = OccupationRisk.all
        ipd_medical_institutions = IpdMedicalInstitution.all
        opd_medical_institutions = OpdMedicalInstitution.all
        nature_of_treatments = NatureOfTreatment.all
        specializations = Specialization.all
        organizations = Organization.all
        organization_levels = OrganizationLevel.all
        organization_designations = OrganizationDesignation.all

        json_response({'message': I18n.t('record_fetched_successfully'),
                       data: {
                         sync_time: Time.now.to_i,
                         languages: languages,
                         family_categories: family_categories,
                         residence_types: residence_types,
                         house_structures: house_structures,
                         house_rent_durations: house_rent_durations,
                         school_types: school_types,
                         schools: schools,
                         toilet_types: toilet_types,
                         toilet_genders: toilet_genders,
                         toilet_place_types: toilet_place_types,
                         govt_family_schemes: govt_family_schemes,
                         health_insurance_family_schemes: health_insurance_family_schemes,
                         castes: castes,
                         religions: religions,
                         marital_statuses: marital_statuses,
                         guardian_absence_reasons: guardian_absence_reasons,
                         govt_personal_schemes: govt_personal_schemes,
                         health_insurance_personal_schemes: health_insurance_personal_schemes,
                         current_classes: current_classes,
                         education_statuses: education_statuses,
                         diseases: diseases,
                         birth_defects: birth_defects,
                         health_behaviours: health_behaviours,
                         health_behaviour_frequencies: health_behaviour_frequencies,
                         health_behaviour_durations: health_behaviour_durations,
                         disabilities: disabilities,
                         cooking_fuels: cooking_fuels,
                         electricities: electricities,
                         transport_vehicles: transport_vehicles,
                         drinking_waters: drinking_waters,
                         occupations: occupations,
                         occupation_risks: occupation_risks,
                         ipd_medical_institutions: ipd_medical_institutions,
                         opd_medical_institutions: opd_medical_institutions,
                         nature_of_treatments: nature_of_treatments,
                         specializations: specializations,
                         organizations: organizations,
                         organization_levels: organization_levels,
                         organization_designations: organization_designations
                       }, status: 'Success'}, 200)
      end

      def dhs
        dhs_metadata = DhsMetadatum.all
        json_response({'message': I18n.t('record_fetched_successfully'),
                       data: {
                         sync_time: Time.now.to_i,
                         dhs_metadata: dhs_metadata,
                       }, status: 'Success'}, 200)
      end
    end
  end
end


