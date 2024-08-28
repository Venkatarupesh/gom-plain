class LabTestVisitSerializer < ApplicationSerializer
  attributes *LabTestVisit.attribute_names.dup - trim_columns
end
