Gatherable.configure do |c|
  c.global_identifier = :gatherable_id

 # c.data_point :data_point_name, :data_point_type, options - see README
  c.data_point :price, :decimal

  #c.data_table :table_name, { column_name: :column_type, column_name2: :column_type }, options - see README
  c.data_table :requested_loan_amount, { requested_loan_amount: :decimal, total_cost: :decimal, monthly_repayment_amount: :decimal }

  #  for both data tables and data points, you'll automatically get a primary key 'table_name_id',
  #  an indexed global identifier, and timestamps

  #If want your db schema to be something besides 'gatherable', uncomment the line below
  #c.schema_name = 'foo_bar'
end
