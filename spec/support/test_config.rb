Gatherable.configure do |c|
  c.global_identifier = :session_id

  c.data_point :price, :decimal

  c.data_table :requested_loan_amount, { requested_loan_amount: :decimal, total_cost: :decimal, monthly_repayment_amount: :decimal }

  #If want your db schema to be something besides 'gatherable', uncomment the line below
  #c.schema_name = 'foo_bar'
end
