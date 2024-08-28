class DhsMetadatum < ApplicationRecord
  belongs_to :seed_data, :polymorphic => true
end
