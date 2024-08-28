class OpdChiefConcernSerializer < ApplicationSerializer
  attributes *OpdChiefConcern.attribute_names.dup - trim_columns
end
