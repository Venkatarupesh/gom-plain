class OpdPrescriptionSerializer < ApplicationSerializer
  attributes *OpdPrescription.attribute_names.dup - trim_columns
end
