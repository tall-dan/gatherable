require 'rails_helper'
require "gatherable/configuration"

describe Gatherable do
  describe '#configuration' do
    context 'data tables' do
      context 'saving data tables' do
        it 'saves data tables' do
          expect(Gatherable.config.data_tables.count).to eql 2
        end

        it 'saves data tables as data with correct name' do
          expect(Gatherable.config.data_tables.first.name).to eql :price
        end

        it 'saves data tables as data tables with correct columns' do
          expect(Gatherable.config.data_tables.first.columns).to eql \
            ({:price => :decimal})
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
        Gatherable.configure { |c| c.data_point :foo, :bar }
      end
    end

    Gatherable.config.data_tables.map(&:name).map(&:to_s).each do |name|

      context 'model_class' do
        let(:klass) { Object.const_get("Gatherable::#{name.classify}") }
        it "creates a model class for #{name}" do
          expect(Object.const_defined?("Gatherable::#{name.classify}")).to be true
        end

        specify "#{name} has the correct table name" do
          expect(klass.table_name).to eql name.pluralize
        end

        specify "#{name} is prefixed with 'gatherable'" do
          expect(klass.table_name_prefix).to eql 'gatherable.'
        end
      end

      it "creates controller for #{name}" do
        expect(Object.const_defined?("Gatherable::#{name.classify.pluralize}Controller")).to be true
      end
    end

    context 'routes' do
      let(:routes) { Gatherable::Engine.routes.routes }

      it 'prefixes route with global identifier' do
        routes.each do |r|
          expect(r.path.spec.to_s).to match(/^\/:session_id\//)
        end
      end

      Gatherable.config.data_tables.map(&:name).map(&:to_s).each do |name|
        it "creates a named path for #{name}" do
          expect(routes.map(&:name)).to include name
        end

        it "creates a named path for #{name}" do
          expect(routes.map(&:name)).to include name.pluralize
        end

        context 'POST route' do
          let(:post_route) { routes.find{ |r| r.name == name.pluralize} }

          it 'creates a POST route' do
            expect(post_route.verb).to eql(/^POST$/)
          end

          it 'creates the correct path' do
            expect(post_route.path.spec.to_s).to eql "/:session_id/#{name.pluralize}(.:format)"
          end
        end

        context 'GET route' do
          let(:get_route) { routes.find{ |r| r.name == name} }

          it 'creates a GET route' do
            expect(get_route.verb).to eql(/^GET$/)
          end

          it 'creates the correct path' do
            expect(get_route.path.spec.to_s).to eql "/:session_id/#{name.pluralize}/:#{name}_id(.:format)"
          end
        end
      end
    end
  end
end
