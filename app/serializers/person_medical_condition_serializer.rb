class PersonMedicalConditionSerializer < ApplicationSerializer
  attributes *PersonMedicalCondition.attribute_names.dup - trim_columns
end
