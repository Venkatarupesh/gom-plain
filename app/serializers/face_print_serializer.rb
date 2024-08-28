class FacePrintSerializer < ApplicationSerializer
  attributes(*FacePrint.attribute_names.dup - trim_columns)
  attribute :vector do |object|
    JSON.parse(object.vector)
  end
end
