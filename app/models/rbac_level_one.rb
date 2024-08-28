class RbacLevelOne < ApplicationRecord
  has_many :rbac_level_twos, dependent: :destroy

  def as_json(options = {})
    super(options).merge(rbac_level_two: rbac_level_twos.as_json)
  end
end
