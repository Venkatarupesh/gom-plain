class IpdNatureTreatmentSerializer < ApplicationSerializer
  attributes *IpdNatureTreatment.attribute_names.dup - trim_columns
end