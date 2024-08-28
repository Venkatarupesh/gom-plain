# app/services/model_crud_service.rb
class CrudService
  def initialize(model_name)
    @model = model_name.constantize
  end

  def create(record,*additional_attributes)
    instance = @model.find_or_initialize_by(id: record['id'])
    data = { 'id': record['id'] }
    if instance.update(record)
      additional_attributes.each do |attr|
        data[attr.to_s] = instance[attr.to_s] if instance.has_attribute?(attr)
      end
      data['flag'] = 1
    else
      data['flag'] = 2
      data['log'] = instance.errors.full_messages
    end
    data
  end

  def delete(record)
    instance = @model.find(record['id'])
    data = { 'id': record['id'] }
    if instance.destroy
      data['flag'] = 1
    else
      data['flag'] = 2
      data['log'] = instance.errors.full_messages
    end
    data
  end
end