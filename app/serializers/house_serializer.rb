class HouseSerializer < ApplicationSerializer
  attributes *House.attribute_names.dup - trim_columns
end
