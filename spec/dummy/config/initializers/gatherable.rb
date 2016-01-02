if Rails.env == 'development'
  Gatherable.configure do |c|
    c.global_identifier :registration_id
    c.data_point :price, :string
  end
end
