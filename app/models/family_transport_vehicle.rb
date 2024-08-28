class FamilyTransportVehicle < ApplicationRecord
  belongs_to :family
  belongs_to :transport_vehicle
end
