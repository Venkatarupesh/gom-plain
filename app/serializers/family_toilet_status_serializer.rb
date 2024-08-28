class FamilyToiletStatusSerializer < ApplicationSerializer
  attributes *FamilyToiletStatus.attribute_names.dup - trim_columns
end