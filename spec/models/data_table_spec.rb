require 'rails_helper'

module Gatherable
  describe DataTable do
    subject(:data_table) { described_class.new(:price, :decimal) }
    context 'generating models' do
      before { subject.classify }
      it 'creates the model class' do
        expect(Object.const_defined?('Gatherable::Price')).to be true
      end

      it 'inherits from ActiveRecord::Base' do
        expect(Gatherable::Price.superclass).to be ActiveRecord::Base
      end
    end

    context 'generating controllers' do
      before { subject.controllerify}
      it 'creates the controller class' do
        expect(Object.const_defined?('Gatherable::PricesController')).to be true
      end

      it 'inherits from Gatherable::ApplicationController' do
        expect(Gatherable::PricesController.superclass).to be Gatherable::ApplicationController
      end
    end
  end
end
