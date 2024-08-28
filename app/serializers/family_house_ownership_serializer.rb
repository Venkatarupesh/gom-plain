class FamilyHouseOwnershipSerializer < ApplicationSerializer
  attributes *FamilyHouseOwnership.attribute_names.dup - trim_columns
end