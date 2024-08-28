class OpdVisitSerializer < ApplicationSerializer
  attributes *OpdVisit.attribute_names.dup - trim_columns
end
