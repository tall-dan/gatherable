class DataPoint
  attr_reader :name, :data_type
  def initialize(name, data_type)
    @name = name
    @data_type = data_type
  end

  def class_name
    name.to_s.classify
  end

  def controller_name
    "#{class_name.pluralize}Controller"
  end

  def classify
    return Gatherable.const_get(class_name) if Gatherable.const_defined?(class_name)
    klass = Gatherable.const_set(class_name, Class.new(ActiveRecord::Base))
    klass.table_name = name.to_s.pluralize
    klass.table_name_prefix = Gatherable.config.schema_name + '.'
    klass
  end

  def controllerify
    return Gatherable.const_get(controller_name) if Gatherable.const_defined?(controller_name)
    Gatherable.const_set(controller_name, Class.new(Gatherable::ApplicationController))
  end
end
