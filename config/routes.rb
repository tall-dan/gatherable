Gatherable::Engine.routes.draw do
  Gatherable.config.data_tables.each do |data_table|
    scope :path => "/:#{Gatherable.config.global_identifier}" do
      resources(data_table.name.to_s.pluralize.to_sym,
                :only => data_table.allowed_controller_actions.map(&:to_sym),
                :param => "#{data_table.name}_id"
               )
    end
  end
end
