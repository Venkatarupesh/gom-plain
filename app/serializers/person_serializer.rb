class PersonSerializer < ApplicationSerializer
  attributes(*Person.attribute_names.dup - trim_columns)
  attribute :date_of_birth do |object|
    object[:date_of_birth].to_i
  end
  attribute :mobile do |object|
    object[:mobile].to_i
  end
end
