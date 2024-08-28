class ApplicationSerializer
  require 'jsonapi/serializer'
  include JSONAPI::Serializer

  def self.trim_columns
    %w[created_at updated_at deleted_at status encrypted_password session_id transaction_id first_time_login is_dashboard_user
       first_name_encrypted middle_name_encrypted last_name_encrypted gender_encrypted date_of_birth_encrypted mobile_encrypted
       vector_encrypted]
  end
  def serializable_hash
    if  super.class == Hash
      super.compact
    elsif super.class== Array
      super.map {|x| x.compact }
    else
      super
    end
  end
end
