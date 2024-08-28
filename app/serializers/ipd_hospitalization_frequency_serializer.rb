class IpdHospitalizationFrequencySerializer < ApplicationSerializer
  attributes *IpdHospitalizationFrequency.attribute_names.dup - trim_columns
end
