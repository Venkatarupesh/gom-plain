class RbacLevelOneSerializer < ApplicationSerializer
  attributes *RbacLevelOne.attribute_names.dup - trim_columns - ["designation"]
end
