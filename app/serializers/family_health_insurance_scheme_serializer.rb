class FamilyHealthInsuranceSchemeSerializer < ApplicationSerializer
  attributes *FamilyHealthInsuranceScheme.attribute_names.dup - trim_columns
end