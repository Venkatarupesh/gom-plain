class FamilyNfsaSerializer < ApplicationSerializer
  attributes *FamilyNfsa.attribute_names.dup - trim_columns
end