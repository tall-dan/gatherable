module Gatherable
  class Configuration
    def global_identifier(identifier = nil)
      @global_identifier = (identifier || @global_identifier)
    end

    def data_point(name, data_type)
      data_points << data_point_instance(name, data_type)
    end

    def data_points
      @data_points ||= []
    end

    private

    def data_point_instance(name, data_type)
      constant_name = name.capitalize
      klass = Object.const_defined?(constant_name) ? Object.const_get(constant_name) : create_class(constant_name)
      klass.new(:name => name, :data_type => data_type)
    rescue ActiveRecord::StatementInvalid => e
      puts 'ActiveRecord Error. Did you create the necessary tables?'
      puts 'Hint: rake gatherable:install:migrations'
      puts 'rake db:migrate'
      raise e
    end

    def create_class(name)
      Object.const_set(name, DataPoint)
    end
  end
end
