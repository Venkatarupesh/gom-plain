class PersonalEnrollmentEducationSerializer < ApplicationSerializer
  attributes *PersonalEnrollmentEducation.attribute_names.dup - trim_columns
end