class OpdDiagnosisSerializer < ApplicationSerializer
  attributes *OpdDiagnosis.attribute_names.dup - trim_columns
end
