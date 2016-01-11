Gatherable::Engine.routes.draw do
  Gatherable.config.data_tables.map{ |dp| dp.name.to_s.pluralize }.each do |data_table|
    scope path: "/:#{Gatherable.config.global_identifier}" do
      resources data_table.to_sym, only: [:show, :create], param: "#{data_table.singularize}_id"
    end
  end
end
