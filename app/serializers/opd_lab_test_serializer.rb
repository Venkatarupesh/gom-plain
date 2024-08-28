class OpdLabTestSerializer < ApplicationSerializer
  attributes *OpdLabTest.attribute_names.dup - trim_columns
end
