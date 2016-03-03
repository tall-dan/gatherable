module Gatherable
  class Configuration
    delegate :empty?, :to => :data_tables
    attr_accessor :global_identifier
    attr_writer :schema_name, :auth_method

    def data_point(name, data_type, options = {})
      data_tables << DataTable.new(name, {name => data_type}, options)
    end

    def data_table(name, columns, options = {})
      data_tables << DataTable.new(name, columns, options)
    end

    def data_tables
      @data_tables ||= []
    end

    def schema_name
      @schema_name || 'gatherable'
    end

    def auth_method
      @auth_method || :session
    end

    def prefixed_resources
      @prefixed_resources ||= []
    end

    def prefixed_resources=(resources)
      all_table_names = DataTable.all.keys
      @prefixed_resources = case resources
      when String, Symbol, Array
        Array(resources).map(&:to_sym) && all_table_names
      when Hash
        if resources.key?(:only)
          Array(resources[:only]).map(&:to_sym) && all_table_names
        elsif resources.key?(:except)
          all_table_names - Array(resources[:except]).map(&:to_sym)
        end
      end
    end
  end
end
