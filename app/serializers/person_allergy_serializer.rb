class PersonAllergySerializer < ApplicationSerializer
  attributes *PersonAllergy.attribute_names.dup - trim_columns
end
