class OpdVitalExaminationSerializer < ApplicationSerializer
  attributes *OpdVitalExamination.attribute_names.dup - trim_columns
end
