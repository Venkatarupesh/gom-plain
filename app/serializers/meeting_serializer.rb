class MeetingSerializer < ApplicationSerializer
  attributes *Meeting.attribute_names.dup - trim_columns
  attribute :meeting_place do |object|
    object.meeting_place_before_type_cast
  end
end
