class Gatherable::RouteDrawer
  def self.draw
    Gatherable::Engine.routes.draw do
      Gatherable.config.data_tables.each do |data_table|
        if Gatherable.config.prefixed_resources.include? data_table.name
          scope :path => "/:#{Gatherable.config.global_identifier}" do
            resources(data_table.name.to_s.pluralize.to_sym,
                      :only => data_table.controller_actions.map(&:to_sym),
                      :param => "#{data_table.name}_id"
                     )
          end
        else
          resources(data_table.name.to_s.pluralize.to_sym,
                    :only => data_table.controller_actions.map(&:to_sym),
                    :param => "#{data_table.name}_id"
                   )
        end
      end
    end
  end
end

Gatherable::RouteDrawer.draw
