class MedicineWarehouseSerializer < ApplicationSerializer
  attributes *MedicineWarehouse.attribute_names.dup - trim_columns
end