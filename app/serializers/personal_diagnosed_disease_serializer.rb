class PersonalDiagnosedDiseaseSerializer < ApplicationSerializer
  attributes *PersonalDiagnosedDisease.attribute_names.dup - trim_columns
end
