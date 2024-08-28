class InventorySerializer < ApplicationSerializer
  attributes *Inventory.attribute_names.dup - trim_columns
end
