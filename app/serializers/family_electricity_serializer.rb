class FamilyElectricitySerializer < ApplicationSerializer
  attributes *FamilyElectricity.attribute_names.dup - trim_columns
end