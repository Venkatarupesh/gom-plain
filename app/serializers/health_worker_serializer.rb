class HealthWorkerSerializer < ApplicationSerializer
  attributes *HealthWorker.attribute_names.dup - trim_columns
end
