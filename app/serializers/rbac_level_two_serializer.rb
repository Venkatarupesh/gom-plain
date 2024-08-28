class RbacLevelTwoSerializer < ApplicationSerializer
  attributes *RbacLevelTwo.attribute_names.dup - trim_columns - ["designation"]
end
