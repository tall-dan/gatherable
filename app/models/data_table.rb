class DataTable
  def self.all
    @all ||= {}
  end

  def self.find_by_name(name)
    all[name.to_sym]
  end

  attr_reader :name, :columns, :new_record_strategy, :allowed_controller_actions,
    :prefix_routes_with_global_id

  def initialize(name, columns, options = {})
    @name = name
    @columns = columns
    @new_record_strategy = options[:new_record_strategy] || :insert
    @allowed_controller_actions = (options[:allowed_controller_actions] || legacy_controller_actions).map(&:to_s)
    @prefix_routes_with_global_id = options[:prefix_routes_with_global_id]
    self.class.all[name.to_sym] = self
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
    klass.table_name = Gatherable.config.schema_name + '.' + name.to_s.pluralize
    klass
  end

  def controllerify
    return Gatherable.const_get(controller_name) if Gatherable.const_defined?(controller_name)
    Gatherable.const_set(controller_name, Class.new(Gatherable::ApplicationController))
  end

  private

  def legacy_controller_actions
    %w[show create]
  end
end
