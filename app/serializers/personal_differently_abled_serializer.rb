class PersonalDifferentlyAbledSerializer < ApplicationSerializer
  attributes *PersonalDifferentlyAbled.attribute_names.dup - trim_columns
end