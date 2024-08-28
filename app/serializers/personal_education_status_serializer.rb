class PersonalEducationStatusSerializer < ApplicationSerializer
  attributes *PersonalEducationStatus.attribute_names.dup - trim_columns
end