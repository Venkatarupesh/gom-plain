class PersonalOpdSerializer < ApplicationSerializer
  attributes *PersonalOpd.attribute_names.dup - trim_columns
end