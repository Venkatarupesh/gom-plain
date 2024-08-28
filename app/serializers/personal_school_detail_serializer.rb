class PersonalSchoolDetailSerializer < ApplicationSerializer
  attributes *PersonalSchoolDetail.attribute_names.dup - trim_columns
end