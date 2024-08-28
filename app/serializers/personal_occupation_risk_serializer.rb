class PersonalOccupationRiskSerializer < ApplicationSerializer
  attributes *PersonalOccupationRisk.attribute_names.dup - trim_columns
end
