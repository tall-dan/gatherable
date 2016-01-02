Gatherable.configure do |c|
  c.global_identifier :session_id

 # c.data_point :data_point_name, :data_point_type
  c.data_point :price, :decimal
end
