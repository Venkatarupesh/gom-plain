class PersonalHealthInsuranceSchemeSerializer < ApplicationSerializer
  attributes *PersonalHealthInsuranceScheme.attribute_names.dup - trim_columns
end
