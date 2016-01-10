module Gatherable
  class Configuration
    delegate :empty?, :to => :data_tables
    attr_accessor :global_identifier
    attr_writer :schema_name, :auth_method

    def data_point(name, data_type)
      data_tables << DataTable.new(name, {name => data_type})
    end

    def data_table(name, columns)
      data_tables << DataTable.new(name, columns)
    end

    def data_tables
      @data_tables ||= []
    end

    def schema_name
      @schema_name || 'gatherable'
    end

    def auth_method
      @auth_method
    end
  end
end
