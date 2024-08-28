class FamilySerializer < ApplicationSerializer
  attributes *Family.attribute_names.dup - trim_columns
end
