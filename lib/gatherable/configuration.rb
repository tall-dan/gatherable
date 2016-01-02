module Gatherable
  class Configuration
    delegate :empty?, :to => :data_points

    def global_identifier(identifier = nil)
      @global_identifier = (identifier || @global_identifier)
    end

    def data_point(name, data_type)
      data_points << DataPoint.new(name, data_type)
    end

    def data_points
      @data_points ||= []
    end
  end
end
