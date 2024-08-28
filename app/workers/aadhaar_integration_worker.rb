# frozen_string_literal: true

require 'net/http'

class AadhaarIntegrationWorker
  TOKENIZATION_API_URL = 'https://aadhaarauthapi.rajasthan.gov.in/doit-aadhaar-enc-dec/demo/hsm/auth/tokenizeV2'
  DETOKENIZATION_API_URL = 'https://aadhaarauthapi.rajasthan.gov.in/doit-aadhaar-enc-dec/demo/hsm/auth/detokenizeV2'

  def self.send_request(url, xml_request)
    uri = URI(url)
    request = Net::HTTP::Post.new(uri)
    request['Content-Type'] = 'application/xml'
    request.body = xml_request

    Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(request)
    end
  end

  def self.tokenize_and_store_aadhaar(person_id, aadhaar_number)
    xml_request = "<AuthRequest uid=\"#{aadhaar_number}\" />"
    response = send_request(TOKENIZATION_API_URL, xml_request)
    return false unless response.is_a?(Net::HTTPSuccess)

    response_xml = Nokogiri::XML(response.body)
    reference_no = response_xml.at('//RefNo')&.text
    status = response_xml.at('//status')&.text
    status_code = response_xml.at('//statusCode')&.text

    return false unless reference_no && status && status_code
    return false unless status == 'Y'

    person = Person.find_by(id: person_id)
    person.update(aadhaar: reference_no)
    true
  end

  def self.detokenize_aadhaar(reference_no)
    xml_request = "<AuthRequest UUID=\"#{reference_no}\" />"
    response = send_request(DETOKENIZATION_API_URL, xml_request)

    return false unless response.is_a?(Net::HTTPSuccess)

    response_xml = Nokogiri::XML(response.body)
    aadhaar_no = response_xml.at('//AadhaarNo')&.text
    status = response_xml.at('//status')&.text
    status_code = response_xml.at('//statusCode')&.text
    puts "Response XML: #{response.body}"
    puts "StatusCode: #{status_code}, Status: #{status}"
    puts "AadhaarNo: #{aadhaar_no}"

    return false unless aadhaar_no && status && status_code
    return false unless status == 'Y'

    aadhaar_no
  end
end
