class PersonalHealthBehaviourSerializer < ApplicationSerializer
  attributes *PersonalHealthBehaviour.attribute_names.dup - trim_columns
end
