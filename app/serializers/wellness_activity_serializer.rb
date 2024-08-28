class WellnessActivitySerializer < ApplicationSerializer
  attributes *WellnessActivity.attribute_names.dup - trim_columns
  attribute :activity_type do |object|
    object.activity_type_before_type_cast
  end
end
