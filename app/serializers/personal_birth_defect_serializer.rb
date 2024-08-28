class PersonalBirthDefectSerializer < ApplicationSerializer
  attributes *PersonalBirthDefect.attribute_names.dup - trim_columns
end
