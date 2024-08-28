class PersonalOccupationSerializer < ApplicationSerializer
  attributes *PersonalOccupation.attribute_names.dup - trim_columns
end
