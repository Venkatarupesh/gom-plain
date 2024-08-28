class PersonalIpdSerializer < ApplicationSerializer
  attributes *PersonalIpd.attribute_names.dup - trim_columns
end