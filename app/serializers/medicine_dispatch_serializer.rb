class MedicineDispatchSerializer < ApplicationSerializer
  attributes *MedicineDispatch.attribute_names.dup - trim_columns
  attribute :dispatch_type do |object|
    object.dispatch_type_before_type_cast
  end
end
