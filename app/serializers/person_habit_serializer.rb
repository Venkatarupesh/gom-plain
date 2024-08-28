class PersonHabitSerializer < ApplicationSerializer
  attributes *PersonHabit.attribute_names.dup - trim_columns
end
