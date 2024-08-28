class HealthFacilitySerializer < ApplicationSerializer
  attributes *HealthFacility.attribute_names.dup - trim_columns
  attribute :facility_type do |object|
    object.facility_type_before_type_cast
  end
end
