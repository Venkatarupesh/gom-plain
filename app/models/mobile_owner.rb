class MobileOwner < ApplicationRecord
  enum order: {
    'Self': 1,
    'Family': 2,
    'Relative': 3,
    'ASHA': 4,
    'ANM': 5
  }
end
