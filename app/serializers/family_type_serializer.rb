class FamilyTypeSerializer < ApplicationSerializer
  attributes *FamilyType.attribute_names.dup - trim_columns
end