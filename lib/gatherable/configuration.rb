module Gatherable
  class Configuration
    delegate :empty?, :to => :data_points
    attr_accessor :global_identifier
    attr_writer :schema_name

    def data_point(name, data_type)
      data_points << DataPoint.new(name, data_type)
    end

    def data_points
      @data_points ||= []
    end

    def schema_name
      @schema_name || 'gatherable'
    end
  end
end
