class OpdNatureTreatmentSerializer < ApplicationSerializer
  attributes *OpdNatureTreatment.attribute_names.dup - trim_columns
end