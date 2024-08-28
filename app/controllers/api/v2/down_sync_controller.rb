module Api
  module V2
    class DownSyncController < ApplicationController
      before_action :villages
      def sync
        page = params[:page].to_i.positive? ? params[:page].to_i : 1
        if params[:last_down_sync_time].to_i.zero?
          full_restore(page)
        else
          point_in_time_restore
        end
      end

      def full_restore(page = 1)
        per_page = 100
        offset = (page - 1) * per_page
        person = if @areas.present?
                   Person.where(area_id: @areas).limit(per_page).offset(offset)
                 else
                   Person.where(village_id: @villages).limit(per_page).offset(offset)
                 end
        person_ids = person.ids
        person_family_ids = Person.where(id: person_ids).pluck(:family_id)
        face_print_ids = Person.where(id: person_ids).pluck(:face_print_id)
        face_prints = FacePrint.where(id: face_print_ids,
                                      updated_at: Time.zone.at(params[:last_down_sync_time].to_i)..DateTime.now.in_time_zone)
        personal_enrollment_educations = PersonalEnrollmentEducation.where(person_id: person_ids)
        personal_education_statuses = PersonalEducationStatus.where(person_id: person_ids)
        personal_school_details = PersonalSchoolDetail.where(person_id: person_ids)
        personal_occupations = PersonalOccupation.where(person_id: person_ids)
        personal_occupation_risks = PersonalOccupationRisk.where(person_id: person_ids)
        personal_health_insurance_schemes = PersonalHealthInsuranceScheme.where(person_id: person_ids)
        personal_govt_schemes = PersonalGovtScheme.where(person_id: person_ids)
        personal_birth_defects = PersonalBirthDefect.where(person_id: person_ids)
        personal_health_behaviours = PersonalHealthBehaviour.where(person_id: person_ids)
        personal_diagnosed_diseases = PersonalDiagnosedDisease.where(person_id: person_ids)
        personal_differently_ableds = PersonalDifferentlyAbled.where(person_id: person_ids)
        personal_ipds = PersonalIpd.where(person_id: person_ids)
        ipd_hospitalization_frequencies = IpdHospitalizationFrequency.where(personal_ipd_id: personal_ipds.ids)
        ipd_nature_treatments = IpdNatureTreatment.where(personal_ipd_id: personal_ipds.ids)
        ipd_advices = IpdAdvice.where(personal_ipd_id: personal_ipds.ids)
        personal_opds = PersonalOpd.where(person_id: person_ids)
        opd_nature_treatments = OpdNatureTreatment.where(personal_opd_id: personal_opds.ids)
        opd_treatments = OpdTreatment.where(personal_opd_id: personal_opds.ids)
        couples = Couple.where(male_id: person_ids)
        families = Family.where(id: person_family_ids)
        family_ids = families.ids
        family_house_ids = Family.where(id: family_ids).pluck(:house_id)
        houses = House.where(id: family_house_ids)
        family_types = FamilyType.where(family_id: family_ids)
        family_house_ownerships = FamilyHouseOwnership.where(family_id: family_ids)
        family_house_structures = FamilyHouseStructure.where(family_id: family_ids)
        family_toilet_statuses = FamilyToiletStatus.where(family_id: family_ids)
        family_toilet_status_ques = FamilyToiletStatusQue.where(family_toilet_status_id: family_toilet_statuses.ids)
        family_drinking_waters = FamilyDrinkingWater.where(family_id: family_ids)
        family_electricities = FamilyElectricity.where(family_id: family_ids)
        family_cooking_fuels = FamilyCookingFuel.where(family_id: family_ids)
        family_transport_vehicles = FamilyTransportVehicle.where(family_id: family_ids)
        family_nfsas = FamilyNfsa.where(family_id: family_ids)
        family_govt_schemes = FamilyGovtScheme.where(family_id: family_ids)
        family_health_insurance_schemes = FamilyHealthInsuranceScheme.where(family_id: family_ids)
        total_people_count = if @areas.present?
                               Person.where(area_id: @areas).count
                             else
                               Person.where(village_id: @villages).count
                             end
        total_pages = (total_people_count / per_page.to_f).ceil
        has_next_page = page < total_pages

        response = {
          sync_time: Time.now.to_i,
          houses: HouseSerializer.new(houses).serializable_hash,
          families: FamilySerializer.new(families).serializable_hash,
          family_types: FamilyTypeSerializer.new(family_types).serializable_hash,
          family_house_ownerships: FamilyHouseOwnershipSerializer.new(family_house_ownerships).serializable_hash,
          family_house_structures: FamilyHouseStructureSerializer.new(family_house_structures).serializable_hash,
          family_toilet_statuses: FamilyToiletStatusSerializer.new(family_toilet_statuses).serializable_hash,
          family_toilet_status_ques: FamilyToiletStatusQueSerializer.new(family_toilet_status_ques).serializable_hash,
          family_drinking_waters: FamilyDrinkingWaterSerializer.new(family_drinking_waters).serializable_hash,
          family_electricities: FamilyElectricitySerializer.new(family_electricities).serializable_hash,
          family_cooking_fuels: FamilyCookingFuelSerializer.new(family_cooking_fuels).serializable_hash,
          family_transport_vehicles: FamilyTransportVehicleSerializer.new(family_transport_vehicles).serializable_hash,
          family_nfsas: FamilyNfsaSerializer.new(family_nfsas).serializable_hash,
          family_govt_schemes: FamilyGovtSchemeSerializer.new(family_govt_schemes).serializable_hash,
          family_health_insurance_schemes: FamilyHealthInsuranceSchemeSerializer.new(family_health_insurance_schemes).serializable_hash,
          face_prints: FacePrintSerializer.new(face_prints).serializable_hash,
          people: PersonSerializer.new(person).serializable_hash,
          personal_enrollment_educations: PersonalEnrollmentEducationSerializer.new(personal_enrollment_educations).serializable_hash,
          personal_education_statuses: PersonalEducationStatusSerializer.new(personal_education_statuses).serializable_hash,
          personal_school_details: PersonalSchoolDetailSerializer.new(personal_school_details).serializable_hash,
          personal_occupations: PersonalOccupationSerializer.new(personal_occupations).serializable_hash,
          personal_occupation_risks: PersonalOccupationRiskSerializer.new(personal_occupation_risks).serializable_hash,
          personal_health_insurance_schemes: PersonalHealthInsuranceSchemeSerializer.new(personal_health_insurance_schemes).serializable_hash,
          personal_govt_schemes: PersonalGovtSchemeSerializer.new(personal_govt_schemes).serializable_hash,
          personal_birth_defects: PersonalBirthDefectSerializer.new(personal_birth_defects).serializable_hash,
          personal_health_behaviours: PersonalHealthBehaviourSerializer.new(personal_health_behaviours).serializable_hash,
          personal_diagnosed_diseases: PersonalDiagnosedDiseaseSerializer.new(personal_diagnosed_diseases).serializable_hash,
          personal_differently_ableds: PersonalDifferentlyAbledSerializer.new(personal_differently_ableds).serializable_hash,
          personal_ipds: PersonalIpdSerializer.new(personal_ipds).serializable_hash,
          ipd_hospitalization_frequencies: IpdHospitalizationFrequencySerializer.new(ipd_hospitalization_frequencies).serializable_hash,
          ipd_nature_treatments: IpdNatureTreatmentSerializer.new(ipd_nature_treatments).serializable_hash,
          ipd_advices: IpdAdviceSerializer.new(ipd_advices).serializable_hash,
          personal_opds: PersonalOpdSerializer.new(personal_opds).serializable_hash,
          opd_nature_treatments: OpdNatureTreatmentSerializer.new(opd_nature_treatments).serializable_hash,
          opd_treatments: OpdTreatmentSerializer.new(opd_treatments).serializable_hash,
          couples: CoupleSerializer.new(couples).serializable_hash,
          pagination: {
            current_page: page,
            total_pages: total_pages,
            total_person_entries: total_people_count,
            has_next_page: has_next_page
          }
        }

        json_response({ 'message': I18n.t('record_fetched_successfully'), data: response, status: 'Success' }, :ok)
      end

      def point_in_time_restore
        houses = if @areas.present?
                   House.where(area_id: @areas)
                 else
                   House.where(village_id: @villages)
                 end
        family = Family.where(house_id: houses.ids)
        family_ids = family.ids
        family_types = down_sync_family('family_types', family_ids)
        family_house_ownerships = down_sync_family('family_house_ownerships', family_ids)
        family_house_structures = down_sync_family('family_house_structures', family_ids)
        family_toilet_statuses = down_sync_family('family_toilet_statuses', family_ids)
        family_toilet_status_ques = FamilyToiletStatusQue.where(family_toilet_status_id: family_toilet_statuses.ids,
                                                                updated_at: Time.zone.at(params[:last_down_sync_time].to_i)..DateTime.now.in_time_zone)
        family_drinking_waters = down_sync_family('family_drinking_waters', family_ids)
        family_electricities = down_sync_family('family_electricities', family_ids)
        family_cooking_fuels = down_sync_family('family_cooking_fuels', family_ids)
        family_transport_vehicles = down_sync_family('family_transport_vehicles', family_ids)
        family_nfsas = down_sync_family('family_nfsas', family_ids)
        family_govt_schemes = down_sync_family('family_govt_schemes', family_ids)
        family_health_insurance_schemes = down_sync_family('family_health_insurance_schemes', family_ids)
        person = if @areas.present?
                   Person.where(area_id: @areas)
                 else
                   Person.where(village_id: @villages)
                 end
        person_ids = person.ids
        face_print_ids = Person.where(id: person_ids).pluck(:face_print_id)
        face_prints = FacePrint.where(id: face_print_ids,
                                      updated_at: Time.zone.at(params[:last_down_sync_time].to_i)..DateTime.now.in_time_zone)
        personal_enrollment_educations = down_sync_person('personal_enrollment_educations', person_ids)
        personal_education_statuses = down_sync_person('personal_education_statuses', person_ids)
        personal_school_details = down_sync_person('personal_school_details', person_ids)
        personal_occupations = down_sync_person('personal_occupations', person_ids)
        personal_occupation_risks = down_sync_person('personal_occupation_risks', person_ids)
        personal_health_insurance_schemes = down_sync_person('personal_health_insurance_schemes', person_ids)
        personal_govt_schemes = down_sync_person('personal_govt_schemes', person_ids)
        personal_birth_defects = down_sync_person('personal_birth_defects', person_ids)
        personal_health_behaviours = down_sync_person('personal_health_behaviours', person_ids)
        personal_diagnosed_diseases = down_sync_person('personal_diagnosed_diseases', person_ids)
        personal_differently_ableds = down_sync_person('personal_differently_ableds', person_ids)
        personal_ipds = down_sync_person('personal_ipds', person_ids)
        ipd_hospitalization_frequencies = IpdHospitalizationFrequency.where(personal_ipd_id: personal_ipds.ids,
                                                                            updated_at: Time.zone.at(params[:last_down_sync_time].to_i)..DateTime.now.in_time_zone)
        ipd_nature_treatments = IpdNatureTreatment.where(personal_ipd_id: personal_ipds.ids,
                                                         updated_at: Time.zone.at(params[:last_down_sync_time].to_i)..DateTime.now.in_time_zone)
        ipd_advices = IpdAdvice.where(personal_ipd_id: personal_ipds.ids,
                                      updated_at: Time.zone.at(params[:last_down_sync_time].to_i)..DateTime.now.in_time_zone)
        personal_opds = down_sync_person('personal_opds', person_ids)
        opd_nature_treatments = OpdNatureTreatment.where(personal_opd_id: personal_opds.ids,
                                                         updated_at: Time.zone.at(params[:last_down_sync_time].to_i)..DateTime.now.in_time_zone)
        opd_treatments = OpdTreatment.where(personal_opd_id: personal_opds.ids,
                                            updated_at: Time.zone.at(params[:last_down_sync_time].to_i)..DateTime.now.in_time_zone)

        couples = Couple.where(male_id: person_ids,
                               updated_at: Time.zone.at(params[:last_down_sync_time].to_i)..DateTime.now.in_time_zone)
        houses = if @areas.present?
                   House.where(area_id: @areas,
                               updated_at: Time.zone.at(params[:last_down_sync_time].to_i)..DateTime.now.in_time_zone)
                 else
                   House.where(village_id: @villages,
                               updated_at: Time.zone.at(params[:last_down_sync_time].to_i)..DateTime.now.in_time_zone)
                 end
        family = Family.where(village_id: @villages,
                              updated_at: Time.zone.at(params[:last_down_sync_time].to_i)..DateTime.now.in_time_zone)
        person = if @areas.present?
                   Person.where(area_id: @areas,
                                updated_at: Time.zone.at(params[:last_down_sync_time].to_i)..DateTime.now.in_time_zone)
                 else
                   Person.where(village_id: @villages,
                                updated_at: Time.zone.at(params[:last_down_sync_time].to_i)..DateTime.now.in_time_zone)
                 end
        response = {
          sync_time: Time.now.to_i,
          houses: HouseSerializer.new(houses).serializable_hash,
          families: FamilySerializer.new(family).serializable_hash,
          family_types: FamilyTypeSerializer.new(family_types).serializable_hash,
          family_house_ownerships: FamilyHouseOwnershipSerializer.new(family_house_ownerships).serializable_hash,
          family_house_structures: FamilyHouseStructureSerializer.new(family_house_structures).serializable_hash,
          family_toilet_statuses: FamilyToiletStatusSerializer.new(family_toilet_statuses).serializable_hash,
          family_toilet_status_ques: FamilyToiletStatusQueSerializer.new(family_toilet_status_ques).serializable_hash,
          family_drinking_waters: FamilyDrinkingWaterSerializer.new(family_drinking_waters).serializable_hash,
          family_electricities: FamilyElectricitySerializer.new(family_electricities).serializable_hash,
          family_cooking_fuels: FamilyCookingFuelSerializer.new(family_cooking_fuels).serializable_hash,
          family_transport_vehicles: FamilyTransportVehicleSerializer.new(family_transport_vehicles).serializable_hash,
          family_nfsas: FamilyNfsaSerializer.new(family_nfsas).serializable_hash,
          family_govt_schemes: FamilyGovtSchemeSerializer.new(family_govt_schemes).serializable_hash,
          family_health_insurance_schemes: FamilyHealthInsuranceSchemeSerializer.new(family_health_insurance_schemes).serializable_hash,
          face_prints: FacePrintSerializer.new(face_prints).serializable_hash,
          people: PersonSerializer.new(person).serializable_hash,
          personal_enrollment_educations: PersonalEnrollmentEducationSerializer.new(personal_enrollment_educations).serializable_hash,
          personal_education_statuses: PersonalEducationStatusSerializer.new(personal_education_statuses).serializable_hash,
          personal_school_details: PersonalSchoolDetailSerializer.new(personal_school_details).serializable_hash,
          personal_occupations: PersonalOccupationSerializer.new(personal_occupations).serializable_hash,
          personal_occupation_risks: PersonalOccupationRiskSerializer.new(personal_occupation_risks).serializable_hash,
          personal_health_insurance_schemes: PersonalHealthInsuranceSchemeSerializer.new(personal_health_insurance_schemes).serializable_hash,
          personal_govt_schemes: PersonalGovtSchemeSerializer.new(personal_govt_schemes).serializable_hash,
          personal_birth_defects: PersonalBirthDefectSerializer.new(personal_birth_defects).serializable_hash,
          personal_health_behaviours: PersonalHealthBehaviourSerializer.new(personal_health_behaviours).serializable_hash,
          personal_diagnosed_diseases: PersonalDiagnosedDiseaseSerializer.new(personal_diagnosed_diseases).serializable_hash,
          personal_differently_ableds: PersonalDifferentlyAbledSerializer.new(personal_differently_ableds).serializable_hash,
          personal_ipds: PersonalIpdSerializer.new(personal_ipds).serializable_hash,
          ipd_hospitalization_frequencies: IpdHospitalizationFrequencySerializer.new(ipd_hospitalization_frequencies).serializable_hash,
          ipd_nature_treatments: IpdNatureTreatmentSerializer.new(ipd_nature_treatments).serializable_hash,
          ipd_advices: IpdAdviceSerializer.new(ipd_advices).serializable_hash,
          personal_opds: PersonalOpdSerializer.new(personal_opds).serializable_hash,
          opd_nature_treatments: OpdNatureTreatmentSerializer.new(opd_nature_treatments).serializable_hash,
          opd_treatments: OpdTreatmentSerializer.new(opd_treatments).serializable_hash,
          couples: CoupleSerializer.new(couples).serializable_hash,
          deleted_records: {
            houses: if @areas.present?
                      HouseSerializer.new(House.where(area_id: @areas,
                                                      deleted_at: Time.zone.at(params[:last_down_sync_time].to_i)..DateTime.now.in_time_zone)).serializable_hash
                    else
                      HouseSerializer.new(House.where(village_id: @villages,
                                                      deleted_at: Time.zone.at(params[:last_down_sync_time].to_i)..DateTime.now.in_time_zone)).serializable_hash
                    end,
            families: FamilySerializer.new(Family.where(house_id: houses.ids,
                                                        deleted_at: Time.zone.at(params[:last_down_sync_time].to_i)..DateTime.now.in_time_zone)).serializable_hash,
            family_types: FamilyTypeSerializer.new(deleted_down_sync_family('family_types',
                                                                            family_ids)).serializable_hash,
            family_house_ownerships: FamilyHouseOwnershipSerializer.new(deleted_down_sync_family('family_house_ownerships',
                                                                                                 family_ids)).serializable_hash,
            family_house_structures: FamilyHouseStructureSerializer.new(deleted_down_sync_family('family_house_structures',
                                                                                                 family_ids)).serializable_hash,
            family_toilet_statuses: FamilyToiletStatusSerializer.new(deleted_down_sync_family('family_toilet_statuses',
                                                                                              family_ids)).serializable_hash,
            family_toilet_status_ques: FamilyToiletStatusQueSerializer.new(FamilyToiletStatusQue.where(family_toilet_status_id: family_toilet_statuses.ids,
                                                                                                       deleted_at: Time.zone.at(params[:last_down_sync_time].to_i)..DateTime.now.in_time_zone)).serializable_hash,
            family_drinking_waters: FamilyDrinkingWaterSerializer.new(deleted_down_sync_family('family_drinking_waters',
                                                                                               family_ids)).serializable_hash,
            family_electricities: FamilyElectricitySerializer.new(deleted_down_sync_family('family_electricities',
                                                                                           family_ids)).serializable_hash,
            family_cooking_fuels: FamilyCookingFuelSerializer.new(deleted_down_sync_family('family_cooking_fuels',
                                                                                           family_ids)).serializable_hash,
            family_transport_vehicles: FamilyTransportVehicleSerializer.new(deleted_down_sync_family('family_transport_vehicles',
                                                                                                     family_ids)).serializable_hash,
            family_nfsas: FamilyNfsaSerializer.new(deleted_down_sync_family('family_nfsas',
                                                                            family_ids)).serializable_hash,
            family_govt_schemes: FamilyGovtSchemeSerializer.new(deleted_down_sync_family('family_govt_schemes',
                                                                                         family_ids)).serializable_hash,
            family_health_insurance_schemes: FamilyHealthInsuranceSchemeSerializer.new(deleted_down_sync_family('family_health_insurance_schemes',
                                                                                                                family_ids)).serializable_hash,
            face_prints: FacePrintSerializer.new(FacePrint.where(id: face_print_ids,
                                                                 deleted_at: Time.zone.at(params[:last_down_sync_time].to_i)..DateTime.now.in_time_zone)).serializable_hash,
            people: if @areas.present?
                      PersonSerializer.new(Person.where(area_id: @areas,
                                                        deleted_at: Time.zone.at(params[:last_down_sync_time].to_i)..DateTime.now.in_time_zone)).serializable_hash
                    else
                      PersonSerializer.new(Person.where(village_id: @villages,
                                                        deleted_at: Time.zone.at(params[:last_down_sync_time].to_i)..DateTime.now.in_time_zone)).serializable_hash
                    end,
            personal_enrollment_educations: PersonalEnrollmentEducationSerializer.new(deleted_down_sync_person('personal_enrollment_educations',
                                                                                                               person_ids)).serializable_hash,
            personal_education_statuses: PersonalEducationStatusSerializer.new(deleted_down_sync_person('personal_education_statuses',
                                                                                                        person_ids)).serializable_hash,
            personal_school_details: PersonalSchoolDetailSerializer.new(deleted_down_sync_person('personal_school_details',
                                                                                                 person_ids)).serializable_hash,
            personal_occupations: PersonalOccupationSerializer.new(deleted_down_sync_person('personal_occupations',
                                                                                            person_ids)).serializable_hash,
            personal_occupation_risks: PersonalOccupationRiskSerializer.new(deleted_down_sync_person('personal_occupation_risks',
                                                                                                     person_ids)).serializable_hash,
            personal_health_insurance_schemes: PersonalHealthInsuranceSchemeSerializer.new(deleted_down_sync_person('personal_health_insurance_schemes',
                                                                                                                    person_ids)).serializable_hash,
            personal_govt_schemes: PersonalGovtSchemeSerializer.new(deleted_down_sync_person('personal_govt_schemes',
                                                                                             person_ids)).serializable_hash,
            personal_birth_defects: PersonalBirthDefectSerializer.new(deleted_down_sync_person('personal_birth_defects',
                                                                                               person_ids)).serializable_hash,
            personal_health_behaviours: PersonalHealthBehaviourSerializer.new(deleted_down_sync_person('personal_health_behaviours',
                                                                                                       person_ids)).serializable_hash,
            personal_diagnosed_diseases: PersonalDiagnosedDiseaseSerializer.new(deleted_down_sync_person('personal_diagnosed_diseases',
                                                                                                         person_ids)).serializable_hash,
            personal_differently_ableds: PersonalDifferentlyAbledSerializer.new(deleted_down_sync_person('personal_differently_ableds',
                                                                                                         person_ids)).serializable_hash,
            personal_ipds: PersonalIpdSerializer.new(deleted_down_sync_person('personal_ipds',
                                                                              person_ids)).serializable_hash,
            ipd_hospitalization_frequencies: IpdHospitalizationFrequencySerializer.new(IpdHospitalizationFrequency.where(personal_ipd_id: personal_ipds.ids,
                                                                                                                         deleted_at: Time.zone.at(params[:last_down_sync_time].to_i)..DateTime.now.in_time_zone)).serializable_hash,
            ipd_nature_treatments: IpdNatureTreatmentSerializer.new(IpdNatureTreatment.where(personal_ipd_id: personal_ipds.ids,
                                                                                             deleted_at: Time.zone.at(params[:last_down_sync_time].to_i)..DateTime.now.in_time_zone)).serializable_hash,
            ipd_advices: IpdAdviceSerializer.new(IpdAdvice.where(personal_ipd_id: personal_ipds.ids,
                                                                 deleted_at: Time.zone.at(params[:last_down_sync_time].to_i)..DateTime.now.in_time_zone)).serializable_hash,
            personal_opds: PersonalOpdSerializer.new(deleted_down_sync_person('personal_opds',
                                                                              person_ids)).serializable_hash,
            opd_nature_treatments: OpdNatureTreatmentSerializer.new(OpdNatureTreatment.where(personal_opd_id: personal_opds.ids,
                                                                                             deleted_at: Time.zone.at(params[:last_down_sync_time].to_i)..DateTime.now.in_time_zone)).serializable_hash,
            opd_treatments: OpdTreatmentSerializer.new(OpdTreatment.where(personal_opd_id: personal_opds.ids,
                                                                          deleted_at: Time.zone.at(params[:last_down_sync_time].to_i)..DateTime.now.in_time_zone)).serializable_hash,
            couples: CoupleSerializer.new(Couple.where(male_id: person_ids,
                                                       deleted_at: Time.zone.at(params[:last_down_sync_time].to_i)..DateTime.now.in_time_zone)).serializable_hash
          }
        }
        json_response({ 'message': I18n.t('record_fetched_successfully'), data: response, status: 'Success' }, :ok)
      end

      private

      def villages
        if @current_user.health_worker.designation_id == 2
          @areas = Area.where(health_worker_id: @current_user.health_worker.id)
          @villages = Village.where(id: @areas.pluck(:village_id))
        elsif [3, 4, 5].include? @current_user.health_worker.health_facility.facility_type_before_type_cast
          hf = @current_user.health_worker.health_facility.id
          temp = @current_user.health_worker.health_facility.phc.sub_centers.pluck(:health_facility_id)
          temp.push(hf)
          @villages = Village.where(health_facility_id: temp)
        elsif @current_user.health_worker.health_facility.facility_type_before_type_cast == 6
          @villages = @current_user.health_worker.health_facility.sub_center.villages
        end
      end

      def down_sync_person(model, person_ids)
        model.classify.constantize.where(person_id: person_ids,
                                         updated_at: Time.zone.at(params[:last_down_sync_time].to_i)..DateTime.now.in_time_zone).active
      end

      def down_sync_family(model, family_ids)
        model.classify.constantize.where(family_id: family_ids,
                                         updated_at: Time.zone.at(params[:last_down_sync_time].to_i)..DateTime.now.in_time_zone).active
      end

      def deleted_down_sync_person(model, person_ids)
        model.classify.constantize.with_deleted.where(person_id: person_ids,
                                                      deleted_at: Time.zone.at(params[:last_down_sync_time].to_i)..DateTime.now.in_time_zone).active
      end

      def deleted_down_sync_family(model, family_ids)
        model.classify.constantize.with_deleted.where(family_id: family_ids,
                                                      deleted_at: Time.zone.at(params[:last_down_sync_time].to_i)..DateTime.now.in_time_zone).active
      end

      def down_sync_play(model, health_worker_ids)
        model.classify.constantize.where(health_worker_id: health_worker_ids,
                                         updated_at: Time.zone.at(params[:last_down_sync_time].to_i)..DateTime.now.in_time_zone).active
      end
    end
  end
end
