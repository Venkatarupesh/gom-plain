class PersonalDiagnosedDisease < ApplicationRecord
  belongs_to :person
  belongs_to :disease
end
