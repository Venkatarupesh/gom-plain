class FacePrint < ApplicationRecord
  include Vault::EncryptedModel
  vault_attribute :vector
  before_save :convert_fields_to_string
  has_many :people
  def convert_fields_to_string
    self.vector = vector.to_s
  end
end