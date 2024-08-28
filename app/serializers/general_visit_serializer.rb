class GeneralVisitSerializer < ApplicationSerializer
  attributes *GeneralVisit.attribute_names.dup - trim_columns
end
