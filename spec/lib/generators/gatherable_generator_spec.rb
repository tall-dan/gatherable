require 'rails_helper'
require 'generators/gatherable/gatherable_generator'

describe GatherableGenerator, :type => :generator do
  let(:file_stream) { IO.new(0) }
  before do
    allow(Gatherable.config).to receive(:data_tables).and_return [DataTable.new(:price, :price => :decimal)]
  end

  it 'creates initializer' do
    generator = described_class.new(['initializer'])
    allow(described_class).to receive(:new) { generator }
    expect(generator).to receive(:copy_file).with('gatherable.rb', 'config/initializers/gatherable.rb')
    Rails::Generators.invoke('gatherable', ['initializer'])
  end


  shared_examples_for 'creating a file' do
    let!(:generator) { described_class.new([generator_target]) }

    before do
      allow(described_class).to receive(:new) { generator }
      allow(generator).to receive(:copy_file)
    end

    context 'setup' do
      it 'creates the destination directory' do
        allow(File).to receive(:open).with(output_file, 'w')
        expect(FileUtils).to receive(:mkdir_p).with(file_destination)
        Rails::Generators.invoke('gatherable', [generator_target])
      end
    end

    context 'for data points' do
      before do
        allow(FileUtils).to receive(:mkdir_p).with(file_destination)
      end

      it 'creates the output file' do
        expect(File).to receive(:open).with(output_file, 'w')
        Rails::Generators.invoke('gatherable', [generator_target])
      end

      it 'correctly writes to the file' do
        allow(File).to receive(:open).with(output_file, 'w').and_yield(file_stream)
        expect(file_stream).to receive(:puts).with(file_content)
        Rails::Generators.invoke('gatherable', [generator_target])
      end

      it 'notifies the user of file creation' do
        allow(File).to receive(:open).with(output_file, 'w')
        allow(File).to receive(:exists?).with(output_file).and_return(false, true)
        expect{Rails::Generators.invoke('gatherable', [generator_target])}.to \
          output("created #{output_file}\n").to_stdout
      end

      it 'notifies the user if file already exists' do
        allow(File).to receive(:open).with(output_file, 'w')
        allow(File).to receive(:exists?).with(output_file) { true }
        allow(Dir).to receive(:[]) { 'a_matching_file' }
        expect{Rails::Generators.invoke('gatherable', [generator_target])}.to \
          output(/Skipping/).to_stdout
      end
    end
  end

  context 'controllers' do
    let(:output_file) { File.join(Rails.root, 'app/controllers/gatherable/prices_controller.rb') }
    let(:file_destination) { 'app/controllers/gatherable' }
    let(:file_content) do
        <<-controller
module Gatherable
  class PricesController < Gatherable::ApplicationController
  end
end
        controller
    end
    let(:generator_target) { 'controllers' }
    it_behaves_like 'creating a file'

    let!(:generator) { described_class.new([generator_target]) }

    before { allow(described_class).to receive(:new) { generator } }

    context 'setup' do
      it 'copies application controller' do
        allow(Gatherable.config).to receive(:data_tables) { [] }
        expect(generator).to receive(:copy_file).with('application_controller.rb', 'app/controllers/gatherable/application_controller.rb')
        Rails::Generators.invoke('gatherable', ['controllers'])
      end
    end
  end

  context 'models' do
    let(:output_file) { File.join(Rails.root, 'app/models/gatherable/price.rb') }
    let(:file_destination) { 'app/models/gatherable' }
    let(:file_content) do
      <<-content
module Gatherable
  class Price < ActiveRecord::Base
    self.table_name = 'prices'
    self.table_name_prefix = 'gatherable.'
  end
end
      content
    end
    let(:generator_target) { 'models' }
    it_behaves_like 'creating a file'
  end
end
