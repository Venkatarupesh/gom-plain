class FamilyCookingFuelSerializer < ApplicationSerializer
  attributes *FamilyCookingFuel.attribute_names.dup - trim_columns
end