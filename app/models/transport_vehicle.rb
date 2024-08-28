class TransportVehicle < ApplicationRecord
  has_many :dhs_metadata, :as => :seed_data
  has_many :family_transport_vehicles, dependent: :destroy
end
