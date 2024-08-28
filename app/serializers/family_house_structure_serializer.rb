class FamilyHouseStructureSerializer < ApplicationSerializer
  attributes *FamilyHouseStructure.attribute_names.dup - trim_columns
end