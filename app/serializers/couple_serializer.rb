class CoupleSerializer < ApplicationSerializer
  attributes *Couple.attribute_names.dup - trim_columns
end