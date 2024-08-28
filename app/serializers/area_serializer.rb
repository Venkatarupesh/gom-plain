class AreaSerializer < ApplicationSerializer
  attributes *Area.attribute_names.dup - trim_columns
end