Gatherable.configure do |c|
  c.global_identifier = :session_id

 # c.data_point :data_point_name, :data_point_type
  c.data_point :price, :decimal

  #If want your db schema to be something besides 'gatherable', uncomment the line below
  #c.schema_name = 'foo_bar'
end
