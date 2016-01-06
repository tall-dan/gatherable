require 'rails_helper'
require "gatherable/configuration"

describe Gatherable do
  describe '#configuration' do
    context 'data tables' do
      context 'saving data tables' do
        it 'saves data tables' do
          expect(Gatherable.config.data_tables.count).to eql 1
        end

        it 'saves data tables as data with correct name' do
          expect(Gatherable.config.data_tables.first.name).to eql :price
        end

        it 'saves data tables as data tables with correct columns' do
          expect(Gatherable.config.data_tables.first.columns).to eql \
            ({:monthly_repayment_amount => :decimal,:price => :decimal, :total_cost => :decimal})
        end
      end
    end

    it 'saves global identifier' do
      expect(Gatherable.config.global_identifier).to eql :session_id
    end
  end

  describe '#configure' do
    context 'already configured' do
      it 'does not change config' do
        expect(Gatherable).to_not receive(:create_models)
        expect(Gatherable).to_not receive(:create_controllers)
        expect(Gatherable).to_not receive(:create_routes)
        Gatherable.configure { |c| c.data_point :foo, :bar }
      end
    end

    it 'creates model classes' do
      expect(Object.const_defined?('Gatherable::Price')).to be true
    end

    specify 'model classes have correct table names' do
      expect(Gatherable::Price.table_name).to eql 'prices'
    end

    specify "model classes are prefixed with 'gatherable'" do
      expect(Gatherable::Price.table_name_prefix).to eql 'gatherable.'
    end

    it 'creates controllers' do
      expect(Object.const_defined?('Gatherable::PricesController')).to be true
    end

    context 'routes' do
      let(:routes) { Gatherable::Engine.routes.routes }

      it 'prefixes route with global identifier' do
        routes.each do |r|
          expect(r.path.spec.to_s).to match(/^\/:session_id\//)
        end
      end

      it 'creates named paths' do
        routes.each do |r|
          expect(r.name).to match(/price/)
        end
      end

      context 'POST route' do
        let(:post_route) { routes.first }

        it 'creates a POST route' do
          expect(post_route.verb).to eql(/^POST$/)
        end

        it 'creates the correct path' do
          expect(post_route.path.spec.to_s).to eql '/:session_id/prices(.:format)'
        end
      end

      context 'GET route' do
        let(:get_route) { routes.last }

        it 'creates a GET route' do
          expect(get_route.verb).to eql(/^GET$/)
        end

        it 'creates the correct path' do
          expect(get_route.path.spec.to_s).to eql '/:session_id/prices/:price_id(.:format)'
        end
      end
    end
  end
end
