class PrescriptionRefillSerializer < ApplicationSerializer
  attributes *PrescriptionRefill.attribute_names.dup - trim_columns
end
