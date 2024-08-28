class OpdTreatmentSerializer < ApplicationSerializer
  attributes *OpdTreatment.attribute_names.dup - trim_columns
end