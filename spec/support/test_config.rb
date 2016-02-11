Gatherable.configure do |c|
  c.global_identifier = :session_id

  c.data_point :price, :decimal, allowed_controller_actions: %w[index show create update destroy]

  c.data_table(
    :requested_loan_amount,
    { requested_loan_amount: :decimal, total_cost: :decimal, monthly_repayment_amount: :decimal },
    new_record_strategy: :update,
    allowed_controller_actions: %w[index show create update destroy]
  )
end
