class FamilyGovtSchemeSerializer < ApplicationSerializer
  attributes *FamilyGovtScheme.attribute_names.dup - trim_columns
end