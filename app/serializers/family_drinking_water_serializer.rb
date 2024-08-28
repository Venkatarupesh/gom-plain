class FamilyDrinkingWaterSerializer < ApplicationSerializer
  attributes *FamilyDrinkingWater.attribute_names.dup - trim_columns
end