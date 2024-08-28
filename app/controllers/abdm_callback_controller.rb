class AbdmCallbackController < ApplicationController
  skip_before_action :authenticate_request!, only: [:share_abha]
  # require '././lib/fhir/apiclasses/care_context'

  # attr_accessor :patient
  # attr_accessor :token
  # attr_accessor :transaction_id

  def get_token
    url = URI("https://dev.abdm.gov.in/gateway/v0.5/sessions")

    https = Net::HTTP.new(url.host, url.port)
    https.use_ssl = true

    request = Net::HTTP::Post.new(url)
    request["Content-Type"] = "application/json"
    request["Cookie"] = "TS011c04bd=01445fed04d27b833366c8229faa8733b3035089fb5d35f3c84879035bb45234691b3784ed690e7cbe49802e54c9a36f5ddc6c491f"
    request.body = JSON.dump({
                               "clientId": "KHUSHI_631045",
                               "clientSecret": "e83f5fc8-7902-454e-b13b-7c4b66455614"
                             })
    response = https.request(request)
    response = JSON.parse(response.read_body)
    response["accessToken"]
  end

  def fetch_modes
    p params.as_json
    json_response({ message: "Thank you" }, :ok)
  end

  def on_fetch_modes
    p params.as_json

    json_response({ message: "Thank you" }, :ok)
  end

  def init_auth(person_id)
    url = URI("https://dev.abdm.gov.in/gateway/v0.5/users/auth/init")

    https = Net::HTTP.new(url.host, url.port)
    https.use_ssl = true


    request = Net::HTTP::Post.new(url)
    request["Content-Type"] = "application/json"
    request["Cookie"] = "TS011c04bd=01445fed04d27b833366c8229faa8733b3035089fb5d35f3c84879035bb45234691b3784ed690e7cbe49802e54c9a36f5ddc6c491f"
    request["Authorization"] = "Bearer #{get_token}"
    request["X-CM-ID"] = "sbx"

    person = Person.find(person_id)
    @person_id = person_id
    req_id = SecureRandom.uuid
    request.body = JSON.dump({
                               "requestId": req_id,
                               "timestamp": Time.now.utc.strftime("%Y-%m-%dT%H:%M:%S.%LZ"),
                               "query": {
                                 "id": person.abha_address_default,
                                 "purpose": "KYC_AND_LINK",
                                 "authMode": "DEMOGRAPHICS",
                                 "requester": {
                                   "type": "HIP",
                                   "id": "kb_hiu"
                                 }
                               }
                             })
    Rails.cache.write(req_id, person_id, expires_in: 2.hours)
    https.request(request)
  end

  def on_init_auth
    self.transaction_id = params[:auth][:transactionId]
    url = URI("https://dev.abdm.gov.in/gateway/v0.5/users/auth/confirm")

    https = Net::HTTP.new(url.host, url.port)
    https.use_ssl = true

    get_token
    request = Net::HTTP::Post.new(url)
    request["Content-Type"] = "application/json"
    request["Cookie"] = "TS011c04bd=01445fed04d27b833366c8229faa8733b3035089fb5d35f3c84879035bb45234691b3784ed690e7cbe49802e54c9a36f5ddc6c491f"
    request["Authorization"] = "Bearer #{get_token}"
    request["X-CM-ID"] = "sbx"

    @person_id = Rails.cache.read(params[:resp][:requestId])
    req_id = SecureRandom.uuid
    Rails.cache.write(req_id, @person_id, expires_in: 2.hours)
    abha_data = AbhaDemographicDatum.find_by(person_id: @person_id)
    request.body = JSON.dump({
                               "requestId": req_id,
                               "timestamp": Time.now.utc.strftime("%Y-%m-%dT%H:%M:%S.%LZ"),
                               "transactionId": self.transaction_id,
                               "credential": {
                                 "demographic": {
                                   "name": abha_data.name,
                                   "gender": case abha_data.gender
                                             when 1
                                               "M"
                                             when 2
                                               "F"
                                             else
                                               "O"
                                             end,
                                   "dateOfBirth": Time.at(abha_data.date_of_birth).to_datetime.strftime("%Y-%m-%d")
                                 }
                               }
                             })
    p request.body
    p https.request(request).code

  end

  def on_confirm_auth
    p params
    @access_token = params[:auth][:accessToken]
    add_care_context(Rails.cache.read(params[:resp][:requestId]))
  end

  def create_care_context(person_id)
    care_contexts = []
    person = Person.find(person_id)
    self.patient = PatientContext.new
    self.patient.referenceNumber = person_id
    self.patient.display = person.name

    couple = Couple.find_by(female_id: person.id)
    unless couple.nil?
      ec = Ec.where(couple_id: couple.id)
      unless ec.nil?
        pregnancies = Pregnancy.where(ec_id: ec.id)
        unless pregnancies.nil?
          ancs = Anc.where(pregnancy_id: pregnancies.pluck(:id))
          unless anc.nil?
            to_be_synced = ancs.filter { |a| a.care_context_id == nil }
            to_be_synced.each do |anc|
              cc = CareContext.new
              cc.display = "ANC " + anc.anc_number + " on " + Time.at(anc.created_at).to_datetime.strftime
              cc.referenceNumber = "ANC-" + anc.id
              care_contexts << cc
            end
          end
        end
      end
    end

    child = Child.where(person_id: person_id)
    unless child.nil?
      child_checkups = ChildCheckup.where(child_id: child.pluck(:id))
      unless child_checkups.nil?
        to_be_synced = child_checkups.filter { |a| a.care_context_id == nil }
        to_be_synced.each do |child_checkup|
          cc = CareContext.new
          cc.display = "Child Checkup " + child_checkup.checkup_no + " on " + Time.at(child_checkup.created_at).to_datetime.strftime
          cc.referenceNumber = "Child-" + child_checkup.id
          care_contexts << cc
        end
      end
    end

    tb_patients = TbPatient.where(person_id: person_id)
    unless tb_patients.nil?
      to_be_synced = tb_patients.filter { |a| a.care_context_id == nil }
      to_be_synced.each do |tb_patient|
        cc = CareContext.new
        cc.display = "Tuberculosis on " + Time.at(tb_patient.created_at).to_datetime.strftime
        cc.referenceNumber = "Tb-" + tb_patient.id
        care_contexts << cc
      end
    end

    leprosy_patients = LeprosyPatient.where(person_id: person_id)
    unless leprosy_patients.nil?
      to_be_synced = leprosy_patients #.filter { |a| a.care_context_id == nil }
      to_be_synced.each do |leprosy_patient|
        cc = CareContext.new
        cc.display = "Leprosy on " + Time.at(leprosy_patient.created_at).to_datetime.strftime
        cc.referenceNumber = "Leprosy-" + leprosy_patient.id
        care_contexts << cc
      end
    end

    cataract_patients = CataractPatient.where(person_id: person_id)
    unless cataract_patients.nil?
      to_be_synced = cataract_patients.filter { |a| a.care_context_id == nil }
      to_be_synced.each do |cataract_patient|
        cc = CareContext.new
        cc.display = "Cataract on " + Time.at(cataract_patient.created_at).to_datetime.strftime
        cc.referenceNumber = "Cataract-" + cataract_patient.id
        care_contexts << cc
      end
    end

    malaria_patients = MalariaScreening.where(person_id: person_id)
    unless malaria_patients.nil?
      to_be_synced = malaria_patients #.filter { |a| a.care_context_id == nil }
      to_be_synced.each do |malaria_patient|
        cc = CareContext.new
        cc.display = "Malaria on " + Time.at(malaria_patient.created_at).to_datetime.strftime
        cc.referenceNumber = "Malaria-" + malaria_patient.id
        care_contexts << cc
      end
    end

    cbac_patients = CbacScreening.where(person_id: person_id)
    unless cbac_patients.nil?
      to_be_synced = cbac_patients #.filter { |a| a.care_context_id == nil }
      to_be_synced.each do |cbac_patient|
        cc = CareContext.new
        cc.display = "NCD on " + Time.at(cbac_patient.created_at).to_datetime.strftime
        cc.referenceNumber = "NCD-" + cbac_patient.id
        care_contexts << cc
      end
    end

    self.patient.careContexts = care_contexts

  end

  def hiu_on_data_request
    if params[:error].nil?
      json_response({ message: "Data requested!" }, :ok)
    else
      json_response({ message: "Invalid Request!" }, :ok)
    end
    data = AbhaBundleDatum.find_by(request_id: params[:resp][:requestId])
    data.update!(txn_id: params[:hiRequest][:transactionId])
  end

  def data_share_complete_notify(consent_id, transaction_id, is_hip = true, care_context_ids = [])
    get_token
    url = URI("https://dev.abdm.gov.in/gateway/v0.5/health-information/notify")

    https = Net::HTTP.new(url.host, url.port)
    https.use_ssl = true

    request = Net::HTTP::Post.new(url)
    request["Content-Type"] = "application/json"
    request["Cookie"] = "TS011c04bd=01445fed04d27b833366c8229faa8733b3035089fb5d35f3c84879035bb45234691b3784ed690e7cbe49802e54c9a36f5ddc6c491f"
    request["Authorization"] = "Bearer #{get_token}"
    request["X-CM-ID"] = "sbx"

    statusResponses = []
    care_context_ids.each do |id|
      statusResponses << {
        "careContextReference": id,
        "hiStatus": "OK",
        "description": id
      }
    end

    request.body = JSON.dump({
                               "requestId": SecureRandom.uuid,
                               "timestamp": Time.now.utc.strftime("%Y-%m-%dT%H:%M:%S.%LZ"),
                               "notification": {
                                 "consentId": consent_id,
                                 "transactionId": transaction_id,
                                 "doneAt": Time.now.utc.strftime("%Y-%m-%dT%H:%M:%S.%LZ"),
                                 "notifier": {
                                   "type": if is_hip
                                             "HIP"
                                           else
                                             "HIU"
                                           end,
                                   "id": if is_hip
                                           "kb_hip"
                                         else
                                           "kb_hiu"
                                         end
                                 },
                                 "statusNotification": {
                                   "sessionStatus": "TRANSFERRED",
                                   "hipId": if is_hip
                                              "kb_hip"
                                            else
                                              "kb_hiu"
                                            end,
                                   "statusResponses": statusResponses.as_json
                                 }
                               }
                             })
    https.request(request)
  end

  def share_bundle_for_care_context

    consent = AbhaConsentDetail.where(consent_id: params[:hiRequest][:consent][:id], hip_or_hiu: 1).first
    care_context_ids = []
    unless consent.nil?
      if consent.consent_granted == 1 && Time.now.utc >= Time.at(consent.from) && Time.now.utc <= Time.at(consent.to)
        care_context_ids = consent.care_context_ids
        bundles = []
        care_context_ids.each do |care_context_id|
          bundles << FhirHelper.share_care_context(care_context_id)
        end

        key = AbhaDataSharingKey.where(consent_id: consent.consent_id, hip_or_hiu: 1).first #, expiry: > Time.now.utc)
        if key.nil?
          key_material = FhirEncryption.generate_ecdh_key_material
          key = AbhaDataSharingKey.create(
            id: BSON::ObjectId.new.to_s,
            consent_id: consent.consent_id,
            expiry: consent.to,
            private_key: key_material['privateKey'],
            public_key: key_material['x509PublicKey'],
            nonce: key_material['nonce'],
            hip_or_hiu: 1
          )
        end

        url = URI(params[:hiRequest][:dataPushUrl].to_s)

        https = Net::HTTP.new(url.host, url.port)
        https.use_ssl = true

        request = Net::HTTP::Post.new(url)
        request["Content-Type"] = "application/json"
        request["Cookie"] = "TS011c04bd=01445fed04d27b833366c8229faa8733b3035089fb5d35f3c84879035bb45234691b3784ed690e7cbe49802e54c9a36f5ddc6c491f"

        bundles.each_with_index do |bundle, index|
          request.body = JSON.dump(
            {
              "pageNumber": index,
              "pageCount": bundles.size,
              "transactionId": params[:transactionId],
              "entries": [
                {
                  "content": FhirEncryption.encrypt_data({
                                                           string_to_encrypt: bundle.as_json.symbolize_keys,
                                                           sender_nonce: key.nonce,
                                                           sender_private_key: key.private_key,
                                                           requester_nonce: params[:hiRequest][:keyMaterial][:nonce],
                                                           requester_public_key: params[:hiRequest][:keyMaterial][:dhPublicKey][:keyValue]
                                                         }),
                  "media": "application/fhir+json",
                  "checksum": "string",
                  "careContextReference": care_context_ids[index]
                }
              ],
              "keyMaterial": {
                "cryptoAlg": "ECDH",
                "curve": "Curve25519",
                "dhPublicKey": {
                  "expiry": Time.at(consent.to).utc.strftime("%Y-%m-%dT%H:%M:%S.%LZ"),
                  "parameters": "Curve25519/32byte random key",
                  "keyValue": key.public_key
                },
                "nonce": key.nonce
              }
            }
          )
          https.request(request)
        end
      end
    end
    data_share_complete_notify(params[:hiRequest][:consent][:id], params[:transactionId], true, care_context_ids)
  end

  def receive_bundle_for_care_context

    consent_id = ""
    care_context_ids = []
    params[:entries].each do |entry|

      data = AbhaBundleDatum.where(txn_id: params[:transactionId]).first
      consent_id = data.consent_id

      key = AbhaDataSharingKey.where(consent_id: data.consent_id, hip_or_hiu: 2).first #, expiry: > Time.now.utc)

      data.update!(
        data: FhirEncryption.decrypt_data(
          {
            encrypted_data: entry[:content][:encryptedData],
            requester_nonce: key.nonce,
            sender_nonce: params[:keyMaterial][:nonce],
            requester_private_key: key.private_key,
            sender_public_key: params[:keyMaterial][:dhPublicKey][:keyValue]
          }
        )
      )
      care_context_ids << entry[:careContextReference]
    end

    data_share_complete_notify(consent_id, params[:transactionId], false, care_context_ids)
  end

  def read_callback
    unless params[:requestId].nil?
      json_response(Rails.cache.read(params[:requestId]), :ok)
    end
  end

  def on_discover
    person = Person.find_by(abha_address_default: params[:patient][:id])
    if person.nil?
      # person = Person.where(mobile: params[:patient][:id])
    else
      create_care_context(person.id)
      matchedBy = "HEALTH_ID"
    end
    get_token
    url = URI("https://dev.abdm.gov.in/gateway/v0.5/care-contexts/on-discover")

    https = Net::HTTP.new(url.host, url.port)
    https.use_ssl = true

    request = Net::HTTP::Post.new(url)
    request["Content-Type"] = "application/json"
    request["Authorization"] = "Bearer #{get_token}"
    request["X-CM-ID"] = params[:patient][:id].split("@")[1]
    request["Cookie"] = "TS011c04bd=01445fed04d27b833366c8229faa8733b3035089fb5d35f3c84879035bb45234691b3784ed690e7cbe49802e54c9a36f5ddc6c491f"

    resp = JSON.dump(
      {
        "requestId": SecureRandom.uuid,
        "timestamp": Time.now.utc.strftime("%Y-%m-%dT%H:%M:%S.%LZ"),
        "transactionId": params[:transactionId],
        "patient": {
          "referenceNumber": person.id,
          "display": person.name,
          "careContexts": patient.careContexts.as_json,
          "matchedBy": [
            matchedBy
          ]
        },
        "resp": {
          "requestId": params[:requestId]
        }
      }
    )
    request.body = resp
    https.request(request)
    json_response({ message: "Thank you" }, :accepted)
  end

  def request_health_data

    consents = AbhaConsentDetail.where(health_worker_id: params[:health_worker_id], person_id: params[:person_id])
    # consents = AbhaConsentDetail.where(health_worker_id: 162, person_id: "ck0mi2eh59a37rlh5qu0")

    get_token

    url = URI("https://dev.abdm.gov.in/gateway/v0.5/health-information/cm/request")

    https = Net::HTTP.new(url.host, url.port)
    https.use_ssl = true

    request = Net::HTTP::Post.new(url)
    request["Content-Type"] = "application/json"
    request["Cookie"] = "TS011c04bd=01445fed04d27b833366c8229faa8733b3035089fb5d35f3c84879035bb45234691b3784ed690e7cbe49802e54c9a36f5ddc6c491f"
    request["Authorization"] = "Bearer #{get_token}"
    request["X-CM-ID"] = "sbx"

    consents.each do |consent|
      key = AbhaDataSharingKey.where(consent_id: consent.consent_id, hip_or_hiu: 2).first #, expiry: > Time.now.utc)
      if key.nil?
        key_material = FhirEncryption.generate_ecdh_key_material
        key = AbhaDataSharingKey.create(
          id: BSON::ObjectId.new.to_s,
          consent_id: consent.consent_id,
          private_key: key_material['privateKey'],
          public_key: key_material['x509PublicKey'],
          nonce: key_material['nonce'],
          hip_or_hiu: 2
        )
      end
      req_id = SecureRandom.uuid
      request.body = JSON.dump(
        {
          "requestId": req_id,
          "timestamp": Time.now.utc,
          "hiRequest": {
            "consent": {
              "id": consent.consent_id
            },
            "dateRange": {
              "from": Time.at(consent.from).utc,
              "to": Time.at(consent.to).utc
            },
            "dataPushUrl": "https://e122-122-171-16-148.ngrok-free.app/data/push",
            "keyMaterial": {
              "cryptoAlg": "ECDH",
              "curve": "Curve25519",
              "dhPublicKey": {
                "expiry": Time.at(consent.to).utc,
                "parameters": "Curve25519/32byte random key",
                "keyValue": key.public_key
              },
              "nonce": key.nonce
            }
          }
        }
      )

      AbhaBundleDatum.create(
        id: BSON::ObjectId.new.to_s,
        consent_id: consent.consent_id,
        person_id: "ck0mi2eh59a37rlh5qu0", # params[:person_id],
        health_worker_id: 162, # params[:health_worker_id],
        request_id: req_id
      )

      https.request(request)
    end
  end

  def on_request
    if params[:acknowledgement][:status] == "SUCCESS"
      self.patient.careContexts.each do |x|
        update_care_context_success(x.referenceNumber)
      end
    end
  end

  def add_care_context(person_id)
    get_token
    url = URI("https://dev.abdm.gov.in/gateway/v0.5/links/link/add-contexts")

    https = Net::HTTP.new(url.host, url.port)
    https.use_ssl = true

    person = Person.find(person_id)
    care_contexts = create_care_context(person_id)
    request = Net::HTTP::Post.new(url)
    request["Content-Type"] = "application/json"
    request["Authorization"] = "Bearer #{get_token}"
    request["X-CM-ID"] = "sbx"
    request["Cookie"] = "TS011c04bd=01445fed04d27b833366c8229faa8733b3035089fb5d35f3c84879035bb45234691b3784ed690e7cbe49802e54c9a36f5ddc6c491f"

    req_id = SecureRandom.uuid
    request.body = JSON.dump(
      {
        "requestId": req_id,
        "timestamp": Time.now.utc.strftime("%Y-%m-%dT%H:%M:%S.%LZ"),
        "link": {
          "accessToken": @access_token,
          "patient": {
            "referenceNumber": person.id,
            "display": person.name,
            "careContexts": care_contexts.as_json
          }
        }
      }
    )
    p request.body
    p https.request(request).code
    Rails.cache.write(req_id, care_contexts, expires_in: 2.hours)
  end

  def on_add_context
    p params
    if !params[:acknowledgement].nil? && params[:acknowledgement][:status] == "SUCCESS"
      Rails.cache.read(params[:resp][:requestId]).each do |x|
        update_care_context_success(x[:referenceNumber])
      end
    end
  end

  def update_care_context_success(care_context_id)
    str = care_context_id.split("-")[0]
    model_id = care_context_id.split("-")[1]
    case str
    when "ANC"
      Anc.find_by(id: model_id).update!(care_context_id: care_context_id)
    when "Pregnancy"
      Pregnancy.find(model_id).update!(care_context_id: care_context_id)
    when "Child"
      ChildCheckup.find(model_id).update!(care_context_id: care_context_id)
    when "Tb"
      TbPatient.find(model_id).update!(care_context_id: care_context_id)
    when "Leprosy"
      LeprosyPatient.find(model_id).update!(care_context_id: care_context_id)
    when "Cataract"
      CataractPatient.find(model_id).update!(care_context_id: care_context_id)
    when "Malaria"
      MalariaScreening.find(model_id).update!(care_context_id: care_context_id)
    when "NCD"
      CbacScreening.find(model_id).update!(care_context_id: care_context_id)
    else
      bundle = nil
    end
    bundle
  end

  def share_abha
    response = params[:profile]
    person = Person.where(first_name: response["patient"]["name"], gender: response["patient"]["gender"], date_of_birth: "#{response["patient"]["dayOfBirth"] || 1}/#{response["patient"]["monthOfBirth"] || 1}/#{response["patient"]["yearOfBirth"]}".to_time.to_i)&.first
    if !person.nil?
      # v = person.abha_demographic_datum.nil? AbhaDemographicDatum.create!(id: BSON::ObjectId.new.to_s, person_id: person.id)

      # v.update!(abha_status: 3,

      #           name: response["name"],
      #           gender: response["gender"],
      #           abha_mobile: mobile,
      #           created_at_app: Time.now.utc.to_i,
      #           updated_at_app: Time.now.utc.to_i,
      #           created_by: response["hipCode"],
      #           updated_by: response["hipCode"],
      #           date_of_birth: "#{response["dayOfBirth"] || 1}/#{response["monthOfBirth"] || 1}/#{response["yearOfBirth"]}".to_time.to_i
      # )
      person.update!(abha_id: response["healthIdNumber"]&.gsub("-", "").to_i, abha_address: response["healthId"], phr_address: response["phrAddress"])
    else
      mobile = 0
      response["patient"]["identifiers"].each do |ident|
        if ident["type"] == "MOBILE"
          mobile = ident["value"]
          break
        end
      end
      #
      # address =  response["address"] != nil ? response["address"] + "," : "" +
      #   response["townName"] != nil ? response["townName"].to_s + "," : "" +
      #   response["subdistrictName"] != nil ? response["subdistrictName"].to_s + "," : "" +
      #   response["districtName"] != nil ? response["districtName"].to_s + "," : "" +
      #   response["stateName"] != nil ? response["stateName"].to_s + "," : "" +
      #   response["pincode"] != nil ? response["pincode"].to_s : "",
      residential_address =        response["patient"]["address"]["district"] != nil ? response["patient"]["address"]["district"].to_s + "," : "" +
          response["patient"]["address"]["state"] != nil ? response["patient"]["address"]["state"].to_s + "," : "" +
          response["patient"]["address"]["pincode"] != nil ? response["patient"]["address"]["pincode"].to_s : ""

      Person.create!(id: BSON::ObjectId.new.to_s, first_name: response["patient"]["name"], gender: response["patient"]["gender"], date_of_birth: "#{response["patient"]["dayOfBirth"] || 1}/#{response["patient"]["monthOfBirth"] || 1}/#{response["patient"]["yearOfBirth"]}".to_time.to_i,abha_id: response["healthIdNumber"]&.gsub("-", "").to_i, abha_address: response["healthId"], phr_address: response["phrAddress"], mobile: mobile, residential_address: residential_address, health_facility_id: HealthFacility.where(hip_code: response["hipCode"]), village_id:1 )
    end
    get_token
    url = URI("https://dev.abdm.gov.in/gateway/v1.0/patients/profile/on-share")

    https = Net::HTTP.new(url.host, url.port)
    https.use_ssl = true

    request = Net::HTTP::Post.new(url)
    request["Content-Type"] = "application/json"
    request["Authorization"] = "Bearer #{get_token}"
    request["X-CM-ID"] = "sbx"
    request.body = JSON.dump({
                               "requestId": SecureRandom.uuid,
                               "timestamp": Time.now.utc.strftime("%Y-%m-%dT%H:%M:%S.%LZ"),
                               "acknowledgement": {
                                 "status": "SUCCESS",
                                 healthId: response["healthIdNumber"],
                                 tokenNumber: 1
                               },
                               "error": nil,
                               "resp": {
                                 "requestId": params[:requestId]
                               }
                             })
    rs = https.request(request)
    p rs.body
    json_response({ message: "ok" }, :accepted)
  end

  def on_notify_hip
    json_response({ message: "ok" }, :ok)

    consent = AbhaConsentDetail.where(consent_id: params[:notification][:consentId], hip_or_hiu: 1).first
    if params[:notification][:status] == "REVOKED"

      unless consent.nil?
        consent.update!(consent_granted: 2)
      end

    elsif params[:notification][:status] == "EXPIRED"

      unless consent.nil?
        consent.update!(consent_granted: 3)
      end

    elsif params[:notification][:status] == "GRANTED"

      if consent.nil?
        consent = AbhaConsentDetail.create!(id: BSON::ObjectId.new.to_s, consent_id: params[:notification][:consentId])
      end

      context_ids = []
      params[:notification][:consentDetail][:careContexts].each do |care_contexts|
        context_ids << care_contexts[:careContextReference].to_s
      end

      consent.update!(
        consent_id: params[:notification][:consentId],
        from: Time.parse(params[:notification][:consentDetail][:permission][:dateRange][:from]),
        to: Time.parse(params[:notification][:consentDetail][:permission][:dateRange][:to]),
        consent_granted: 1,
        signature: params[:notification][:signature],
        care_context_ids: context_ids,
        bundle_types: params[:notification][:consentDetail][:hiTypes],
        health_worker_id: nil,
        hip_or_hiu: 1,
        person_id: params[:notification][:consentDetail][:careContexts][0][:patientReference],
        request_id: params[:requestId]
      )

    end

    get_token
    url = URI("https://dev.abdm.gov.in/gateway/v0.5/consents/hip/on-notify")

    https = Net::HTTP.new(url.host, url.port)
    https.use_ssl = true

    request = Net::HTTP::Post.new(url)
    request["Content-Type"] = "application/json"
    request["Authorization"] = "Bearer #{get_token}"
    request["X-CM-ID"] = "sbx"
    request["Cookie"] = "TS011c04bd=01445fed04d27b833366c8229faa8733b3035089fb5d35f3c84879035bb45234691b3784ed690e7cbe49802e54c9a36f5ddc6c491f"

    request.body = JSON.dump({
                               "requestId": SecureRandom.uuid,
                               "timestamp": Time.now.utc.strftime("%Y-%m-%dT%H:%M:%S.%LZ"),
                               "acknowledgement": {
                                 "status": "OK",
                                 "consentId": params[:notification][:consentId]
                               },
                               "resp": {
                                 "requestId": params[:requestId]
                               }
                             })
    https.request(request)
  end

  def on_notify_hiu
    json_response({ message: "ok" }, :ok)

    consents = []
    params[:notification][:consentArtefacts].each do |consent_id|
      cons = AbhaConsentDetail.where(consent_id: consent_id[:id], hip_or_hiu: 2)
      unless cons.nil?
        consents << cons
      end
    end
    if params[:notification][:status] == "REVOKED"

      unless consents.blank?
        consents.each do |consent|
          consent.update!(consent_granted: 2)
        end
      end

    elsif params[:notification][:status] == "EXPIRED"

      unless consents.blank?
        consents.each do |consent|
          consent.update!(consent_granted: 3)
        end
      end

    elsif params[:notification][:status] == "GRANTED"
      consent = AbhaConsentDetail.where(request_id: params[:notification][:consentRequestId], hip_or_hiu: 2).first
      consent.as_json
      unless consent.nil?
        consents = []
        params[:notification][:consentArtefacts].each do |care_contexts|
          consents << care_contexts[:careContextReference]
        end

        consents.each_with_index do |cons, index|
          if index == 0
            consent.update!(
              consent_id: params[:notification][:consentArtefacts][0][:id],
              consent_granted: 1
            )
          else
            cons = consent.dup
            cons.create!(
              id: BSON::ObjectId.new.to_s,
              consent_id: params[:notification][:consentArtefacts][0][:id],
              consent_granted: 1
            )
          end
        end

      end

    end

    get_token
    url = URI("https://dev.abdm.gov.in/gateway/v0.5/consents/hip/on-notify")

    https = Net::HTTP.new(url.host, url.port)
    https.use_ssl = true

    request = Net::HTTP::Post.new(url)
    request["Content-Type"] = "application/json"
    request["Authorization"] = "Bearer #{get_token}"
    request["X-CM-ID"] = "sbx"
    request["Cookie"] = "TS011c04bd=01445fed04d27b833366c8229faa8733b3035089fb5d35f3c84879035bb45234691b3784ed690e7cbe49802e54c9a36f5ddc6c491f"

    request.body = JSON.dump({
                               "requestId": SecureRandom.uuid,
                               "timestamp": Time.now.utc.strftime("%Y-%m-%dT%H:%M:%S.%LZ"),
                               "acknowledgement": {
                                 "status": "OK",
                                 "consentId": params[:notification][:consentId]
                               },
                               "resp": {
                                 "requestId": params[:requestId]
                               }
                             })

    https.request(request)
  end

  def on_init_consent

    get_token
    consent = AbhaConsentDetail.where(request_id: params[:resp][:requestId], consent_granted: -1)
    unless consent.nil?
      consent.update!(request_id: params[:consentRequest][:id], consent_granted: -1)
    end
    json_response({ message: "ok" }, :ok)
  end

  def init_consent

    hw = HealthWorker.find(params[:hw_id])
    person = Person.find(params[:person_id])
    get_token
    url = URI("https://dev.abdm.gov.in/gateway/v0.5/consent-requests/init")

    https = Net::HTTP.new(url.host, url.port)
    https.use_ssl = true

    request_id = SecureRandom.uuid
    request = Net::HTTP::Post.new(url)
    request["Content-Type"] = "application/json"
    request["Authorization"] = "Bearer #{get_token}"
    request["X-CM-ID"] = "sbx"
    request["Cookie"] = "TS011c04bd=01445fed04d27b833366c8229faa8733b3035089fb5d35f3c84879035bb45234691b3784ed690e7cbe49802e54c9a36f5ddc6c491f"
    now = Time.now.utc
    req = JSON.dump(
      {
        "requestId": request_id,
        "timestamp": now.strftime("%Y-%m-%dT%H:%M:%S.%LZ"),
        "consent": {
          "purpose": {
            "text": "Medical History",
            "code": "CAREMGT"
          },
          "patient": {
            "id": person.abha_address_default
          },
          "hiu": {
            "id": "kb_hiu"
          },
          "requester": {
            "name": hw.name,
            "identifier": {
              "type": hw.designation,
              "value": hw.id,
              "system": "https://nirogi.rajasthan.gov.in"
            }
          },
          "hiTypes": %w[OPConsultation DiagnosticReport Prescription ImmunizationRecord DischargeSummary HealthDocumentRecord WellnessRecord],
          "permission": {
            "accessMode": "VIEW",
            "dateRange": {
              "from": now.strftime("%Y-%m-%dT%H:%M:%S.%LZ"),
              "to": (now + 1.year).strftime("%Y-%m-%dT%H:%M:%S.%LZ")
            },
            "dataEraseAt": (now + 1.year).strftime("%Y-%m-%dT%H:%M:%S.%LZ"),
            "frequency": {
              "unit": "HOUR",
              "value": 1,
              "repeats": 0
            }
          }
        }
      }
    )
    request.body = req

    a = https.request(request)
    if a.code == "202" || a.code == "204" || a.code == "200"
      AbhaConsentDetail.create!(
        id: BSON::ObjectId.new.to_s,
        health_worker_id: hw.id,
        request_id: request_id,
        from: now,
        to: (now + 1.year),
        bundle_types: %w[OPConsultation DiagnosticReport Prescription ImmunizationRecord DischargeSummary HealthDocumentRecord WellnessRecord],
        person_id: person.id,
        consent_granted: -1,
        hip_or_hiu: 2
      )
    end
  end

  def fetch_consent_details
    p params.as_json
  end

  def bg_del
    consents_to_delete = AbhaConsentDetail.where("to < ?", Time.now).where.not(consent_granted: 1).pluck(:id)
    AbhaBundleDatum.delete(AbhaBundleDatum.where(consent_id: consents_to_delete).pluck(:id))
    AbhaDataSharingKey.delete(AbhaDataSharingKey.where(consent_id: consents_to_delete).pluck(:id))
    AbhaDataSharingKey.delete(AbhaDataSharingKey.where("expiry < ?", Time.now).pluck(:id))
    AbhaConsentDetail.delete(consents_to_delete)
  end

  def text_notify_on_sync(model, person_id)
    get_token
    url = URI("https://dev.abdm.gov.in/gateway/v0.5/patients/sms/notify2")

    https = Net::HTTP.new(url.host, url.port)
    https.use_ssl = true

    person = Person.find(person_id)
    request = Net::HTTP::Post.new(url)
    request["Content-Type"] = "application/json"
    request["Cookie"] = "TS011c04bd=01445fed04d27b833366c8229faa8733b3035089fb5d35f3c84879035bb45234691b3784ed690e7cbe49802e54c9a36f5ddc6c491f"
    request["Authorization"] = "Bearer #{get_token}"
    request["X-CM-ID"] = "sbx"
    request.body = JSON.dump(
      {
        "requestId": SecureRandom.uuid,
        "timestamp": Time.now.utc.strftime("%Y-%m-%dT%H:%M:%S.%LZ"),
        "notification": {
          "phoneNo": person.mobile,
          "hip": {
            "name": "KhushiBaby",
            "id": FhirHelper.get_care_context_id(model)
          }
        }
      }
    )
    response = https.request(request)
    response = JSON.parse(response.read_body)
  end
end