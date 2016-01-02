require 'rails_helper'
require 'generators/gatherable/gatherable_generator'

describe GatherableGenerator, :type => :generator do
  before(:context) do
    Gatherable.configure do |c|
      c.global_identifier :random_var
      c.data_point :price, :float
    end
  end

  it 'creates migrations' do
    expect{Rails::Generators.invoke('gatherable', ['migrations'])}.to\
      change{Dir['db/migrate'].count}.from(0).to(1)
  end

  it 'creates initializer' do
    expect{Rails::Generators.invoke('gatherable', ['initialize'])}.to\
      change{File.exists?('config/initializers/gatherable.rb')}.from(false).to(true)
  end

  after do
    FileUtils.rm_rf('db')
    File.delete('config/initializers/gatherable.rb') if File.exists?('config/initializers/gatherable.rb')
  end
end
