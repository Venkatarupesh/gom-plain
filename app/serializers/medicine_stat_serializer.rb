class MedicineStatSerializer < ApplicationSerializer
  attributes *MedicineStat.attribute_names.dup - trim_columns
end
