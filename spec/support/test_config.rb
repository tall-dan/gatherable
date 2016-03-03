Gatherable.configure do |c|
  c.global_identifier = :session_id
  c.data_point :price, :decimal, allowed_controller_actions: %w[index show create update destroy]
end
