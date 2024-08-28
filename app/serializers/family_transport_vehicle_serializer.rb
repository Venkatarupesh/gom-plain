class FamilyTransportVehicleSerializer < ApplicationSerializer
  attributes *FamilyTransportVehicle.attribute_names.dup - trim_columns
end