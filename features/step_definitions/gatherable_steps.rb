Given(/^I am collecting a one dimensional data point called '([a-z]*)'$/) do |data_point|
  all_actions = [:index, :show, :create, :update, :destroy]
  @data_table = Gatherable.config.data_tables.find{ |table| table.name == data_point.to_sym }
  allow(@data_table).to receive(:controller_actions).and_return(all_actions)
end

Given(/^the gatherable API doesn't require global id$/) do
  @global_identifier = ''
  allow(SecureRandom).to receive(:urlsafe_base64) { @internal_identifier }
  allow(Gatherable.config.prefixed_resources).to receive(:include?) { false }
  Gatherable::RouteDrawer.draw
end

Given(/^the gatherable API requires global id$/) do
  @global_identifier = SecureRandom.urlsafe_base64
  allow(SecureRandom).to receive(:urlsafe_base64) { @global_identifier }
  allow(Gatherable.config.prefixed_resources).to receive(:include?) { true }
  Gatherable::RouteDrawer.draw
end

When(/^I show an object$/) do
  visit '/'
  @instance = @data_table.classify.create(@data_table.name => 3.00)
  expect(@data_table.classify).to receive(:find_by!)
  page.execute_script("Gatherable.show('#{@data_table.name}', #{@instance.id}, '#{@global_identifier}')")
  wait_for_ajax
end

When(/^I index an object$/) do
  visit '/'
  @instance = @data_table.classify.create(@data_table.name => 3.00)
  expect(@data_table.classify).to receive(:where)
  page.execute_script("Gatherable.index('#{@data_table.name}', '#{@global_identifier}')")
  wait_for_ajax
end

When(/^I create an object$/) do
  visit '/'
  @price =  Random.rand.round(2)
  page.execute_script("Gatherable.create('#{@data_table.name}', {#{@data_table.name}: #{@price}}, '#{@global_identifier}')")
end

When(/^I update an object$/) do
  visit '/'
  @instance = @data_table.classify.create(@data_table.name => 3.00)
  @price =  Random.rand.round(2)
  page.execute_script("Gatherable.update('#{@data_table.name}', #{@instance.id}, {#{@data_table.name}: #{@price}}, '#{@global_identifier}')")
end

When(/^I destroy an object$/) do
  visit '/'
  @instance = @data_table.classify.create(@data_table.name => 3.00)
  page.execute_script("Gatherable.destroy('#{@data_table.name}', #{@instance.id}, '#{@global_identifier}')")
end

Then(/^the object will be showed$/) do
  # tested in the when clause :/
end

Then(/^the object will be indexed$/) do
  # tested in the when clause :/
end

Then(/^the object will be createed$/) do
  wait_for_ajax
  expect(@data_table.classify.where(@data_table.name => @price)).to_not be_empty
end

Then(/^the object will be updateed$/) do
  wait_for_ajax
  puts "looking for #{@price}"
  puts "have"
  puts @data_table.classify.all.map(&:price)
  expect(@data_table.classify.where(@data_table.name => @price)).to_not be_empty
end

Then(/^the object will be destroyed$/) do
  wait_for_ajax
  expect{@instance.reload}.to raise_error(ActiveRecord::RecordNotFound)
end
