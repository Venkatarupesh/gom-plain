class IpdAdviceSerializer < ApplicationSerializer
  attributes *IpdAdvice.attribute_names.dup - trim_columns
end