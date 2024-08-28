class PersonalGovtSchemeSerializer < ApplicationSerializer
  attributes *PersonalGovtScheme.attribute_names.dup - trim_columns
end
