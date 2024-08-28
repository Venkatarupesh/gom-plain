class FamilyToiletStatusQueSerializer < ApplicationSerializer
  attributes *FamilyToiletStatusQue.attribute_names.dup - trim_columns
end