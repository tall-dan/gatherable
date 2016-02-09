require 'rails_helper'

module Gatherable
  describe DataTable do
    subject(:data_table) { described_class.new(:my_data_point, :decimal) }

    it 'defines classes' do
      expect(subject.classify).to eql Gatherable::MyDataPoint
    end

    it 'defines controllers' do
      expect(subject.controllerify).to eql Gatherable::MyDataPointsController
    end

    it 'errors without creates required columns' do #these tests doesnt really belong here
      expect{Gatherable::Price.create(session_id: 1, price: nil)}.to raise_error(ActiveRecord::StatementInvalid)
    end

    it 'does not error with required columns' do
      expect{Gatherable::Price.create(session_id: 1, price: 30)}.to_not raise_error
    end

    it 'saves a record of instances in memory' do
      data_table
      expect(DataTable.find_by_name(:my_data_point)).to eql data_table
    end
  end
end
