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

    it 'creates a module' do
      expect(Object.const_defined?("Gatherable")).to be true
    end

    Gatherable.config.data_tables.map(&:name).map(&:to_s).each do |name|

      context 'model_class' do
        let(:klass) { Gatherable.const_get("#{name.classify}") }
        it "creates a model class for #{name}" do
          expect(Gatherable.const_defined?(name.classify)).to be true
        end

        specify "#{name} has the correct table name" do
          expect(klass.table_name).to eql Gatherable.config.schema_name + '.' + name.pluralize
        end

        specify "#{name} inherits from ActiveRecord::Base" do
          expect(klass.superclass).to be ActiveRecord::Base
        end
      end

      it "creates controller for #{name}" do
        expect(Gatherable.const_defined?("#{name.classify.pluralize}Controller")).to be true
      end

      specify "#{name} controller inherits from Gatherable::ApplicationController" do
        expect(Gatherable::PricesController.superclass).to be Gatherable::ApplicationController
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

        context 'generating routes' do
          let(:create_route) { routes.find{ |r| r.verb == /^POST$/ && r.path.spec.to_s == "/:session_id/#{name.pluralize}(.:format)" } }
          let(:show_route) { routes.find{ |r| r.verb == /^GET$/ && r.path.spec.to_s == "/:session_id/#{name.pluralize}/:#{name}_id(.:format)" } }
          let(:index_route) { routes.find{ |r| r.verb == /^GET$/ && r.path.spec.to_s == "/:session_id/#{name.pluralize}(.:format)" } }
          let(:update_route) { routes.find{ |r| r.verb == /^PUT$/ && r.path.spec.to_s == "/:session_id/#{name.pluralize}/:#{name}_id(.:format)" } }
          let(:patch_route) { routes.find{ |r| r.verb == /^PATCH$/ && r.path.spec.to_s == "/:session_id/#{name.pluralize}/:#{name}_id(.:format)" } }
          let(:delete_route) { routes.find{ |r| r.verb == /^DELETE$/ && r.path.spec.to_s == "/:session_id/#{name.pluralize}/:#{name}_id(.:format)" } }

          specify 'for create' do
            expect(create_route).to_not be_nil
          end

          specify 'for show' do
            expect(show_route).to_not be_nil
          end

          specify 'for index' do
            expect(index_route).to_not be_nil
          end

          specify 'for update' do
            expect(update_route).to_not be_nil
          end

          specify 'for patch' do
            expect(patch_route).to_not be_nil
          end

          specify 'for delete' do
            expect(delete_route).to_not be_nil
          end
        end
      end
    end
  end
end
