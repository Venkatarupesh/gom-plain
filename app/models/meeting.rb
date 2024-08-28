class Meeting < ApplicationRecord
  enum meeting_place: {"At Village": 1, "At Block": 2, "At Health facility": 3}
end
