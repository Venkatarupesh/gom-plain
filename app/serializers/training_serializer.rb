class TrainingSerializer < ApplicationSerializer
  attributes *Training.attribute_names.dup - trim_columns
end
