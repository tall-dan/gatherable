require 'rails_helper'

describe 'Gatherable::PricesController', :type => :request do

  let(:data_table) { Gatherable.config.data_tables.first }
  let(:model_name) { data_table.name.to_s }
  let(:model_class) { data_table.classify }
  let(:controller_class) { data_table.controllerify }
  let(:global_id) { 'session_id123' }
  let(:id) { 1 }

  let(:params_prefix) { prefix.blank? ? { "session_id" => global_id } : {} }

  let(:index) { get "/gatherable/#{prefix}#{model_name.to_s.pluralize}.json" }

  let(:show) do
    get "/gatherable/#{prefix}#{model_name.to_s.pluralize}/#{id}.json"
  end

  let(:create) do
    post "/gatherable/#{prefix}#{model_name.to_s.pluralize}.json", params
  end

  let(:update) do
    put "/gatherable/#{prefix}#{model_name.to_s.pluralize}/#{id}.json", params
  end

  let(:destroy) do
    delete "/gatherable/#{prefix}#{model_name.to_s.pluralize}/#{id}.json"
  end

  let(:json_response) { JSON.parse(response.body) }

  before do
    allow(SecureRandom).to receive(:urlsafe_base64) { global_id }
    allow(data_table).to receive(:allowed_controller_actions) { [:show, :index, :create, :update, :destroy] }
    @controller = controller_class.new
  end

  shared_examples "#index" do
    context 'successful request' do
      let(:instance) { model_class.new(model_params) }
      let(:model_params) { { "#{model_name}_id" => 0, model_name.to_s => "3.0"} }

      before do
        allow(model_class).to receive(:where) { [instance] }
      end

      it 'returns a 302 response code' do
        index
        expect(response.status).to eql 302
      end

      it 'returns a json array' do
        index
        expect(json_response).to match([a_hash_including(model_params)])
      end
    end

    context 'unsuccesful request' do
      context 'no results found' do
        it 'returns an empty json response' do
          index
          expect(json_response).to be_empty
        end
      end
    end
  end

  shared_examples '#show' do
    let(:instance) { model_class.new(model_params) }
    let(:model_params) { { model_name.to_s => "3.0", "#{model_name}_id" => id} }

    before do
      allow(model_class).to receive(:find_by!).with("#{model_name}_id" => id.to_s, :session_id => global_id).and_return(instance)
      allow(model_class).to receive(:find_by!).with("#{model_name}_id" => '0', :session_id => global_id).and_raise(ActiveRecord::RecordNotFound)
    end

    context 'record found' do
      before do
        show
      end

      it 'returns the record' do
        expect(json_response).to include(model_params)
      end

      specify 'the response code is 302' do
        expect(response.status).to eql 302
      end
    end

    context 'record not found' do
      let(:id) { 0 }
      before do
        show
      end

      specify 'the response code is 404' do
        expect(response.status).to eql 404
      end

      it 'returns errors' do
        expect(json_response).to eql({"errors"=>"ActiveRecord::RecordNotFound"})
      end
    end
  end

  shared_examples '#create' do

    shared_examples 'successful object creation' do
      let(:params) {{ model_name => model_params }}
      before do
        model_params.merge!('session_id' => global_id)
      end

      it 'creates an object' do
        expect(model_class).to receive(:create!).with(model_params)
        create
      end

      it "contains all attributes of the model" do
        create
        model_class.column_names.each do |attr|
          expect(json_response.keys).to include(attr)
        end
      end

      it "returns the saved values of the created model" do
        create
        model_params.stringify_keys.each do |(attr, val)|
          expect(json_response[attr]).to eql val
        end
      end

      it 'adds a timestamp to the record' do
        create
        expect(json_response['created_at']).to_not be_nil
      end

      specify 'the object created is valid' do
        create
        expect(instance).to be_valid
      end

      specify 'status is 201' do
        create
        expect(response.status).to eql 201
      end

      context 'new_record_strategy = :update' do
        before do
          allow(data_table).to receive(:new_record_strategy).and_return :update
        end

        context 'updating existing record' do
          let!(:existing_record) { model_class.create(model_name => '76', :session_id => 'session_id123') }

          it 'sets correct values' do
            create
            existing_record.reload
            model_params.each do |(attr, val)|
              expect(existing_record.send(attr).to_s).to eql val
            end
          end

          it 'does not create a new record' do
            expect{create}.to_not change{model_class.count}
          end
        end

        context 'creating new record' do
          it 'creates a valid record' do
            expect{create}.to change{model_class.count}.by 1
          end
        end

        specify 'status is 200' do
          create
          expect(response.status).to eql 200
        end
      end
    end

    context 'correct param format' do
      let(:model_params) { { model_name => "3.0"} }
      let(:instance) { model_class.new(model_params) }
      it_behaves_like 'successful object creation'
    end


    context 'incorrect param format' do
      context 'required params not given' do
        let(:params) { { :yolo => 'swag' } }
        specify 'the response status is 422' do
          create
          expect(response.status).to eql 422
        end
      end

      context 'required params + junk params given' do
        let(:model_params) { { model_name => "3.0"} }
        let(:junk_params) { { 'yolo' => 'swag' } }
        let(:params) { { model_name => model_params.merge(junk_params)}.merge(junk_params) }
        let(:instance) { model_class.new(model_params.merge(:session_id => 'session_id123')) }
        it_behaves_like 'successful object creation'
      end
    end
  end

  shared_examples '#update' do
    describe '#update' do
      let(:model_params) { { model_name => '3.0', "#{model_name}_id" => id } }
      let(:instance) { model_class.new(model_params) }
      let(:params) { { model_name => { model_name => '4.0' } } }

      context 'successful request' do
        before do
          instance.save!
          update
        end

        it 'updates the record' do
          expect(instance.reload.send(model_name.to_sym).to_s).to eql '4.0'
        end

        it 'renders an updated version of the record' do
          expect(json_response).to include( {model_name.to_s => '4.0'} )
        end
      end

      context 'with invalid data' do
        let(:params) { { model_name => Date.today } }

        before do
          allow(model_class).to receive(:find_by!).and_return(instance)
          update
        end

        specify 'the response code is 422' do
          expect(response.status).to eql 422
        end

        it 'returns errors' do
          expect(json_response).to have_key('errors')
        end
      end

      context 'record not found' do
        let(:id) { 0 }
        let(:params) { {} }
        before do
          update
        end

        specify 'the response code is 404' do
          expect(response.status).to eql 404
        end

        it 'returns errors' do
          expect(json_response).to eql({"errors"=>"Couldn't find Gatherable::#{model_name.to_s.classify}"})
        end
      end
    end
  end

  shared_examples '#destroy' do
    let(:model_params) { { model_name => '3.0' } }
    let(:instance) { model_class.new(model_params.merge(:session_id => 'session_id123')) }
    let(:id) { instance.reload.id }

    context 'successful request' do
      before do
        instance.save!
        id
        destroy
      end

      it 'deletes the record' do
        expect(model_class.where("#{model_name}_id" => id)).to be_empty
      end

      it 'renders nothing' do
        expect(response.body).to be_empty
      end

      it 'has a successful response code' do
        expect(response.status).to eql 204
      end
    end

    context 'record not found' do
      let(:id) { 0 }

      before do
        destroy
      end

      specify 'the response code is 404' do
        expect(response.status).to eql 404
      end

      it 'returns errors' do
        expect(json_response).to eql({"errors"=>"Couldn't find Gatherable::#{model_name.to_s.classify}"})
      end
    end
  end

  shared_examples 'auth failed' do
    let(:prefix) { "#{global_id}123/" }

    before do
      allow(Gatherable.config).to receive(:auth_method) { :session }
      allow_any_instance_of(@controller.class).to receive(:session) { {:session_id => global_id } }
      perform_request.call
    end

    it 'returns an empty body' do
      expect(response.body).to be_empty
    end

    it 'returns a response status of unauthorized' do
      expect(response.status).to eql 401
    end
  end

  context 'unique identifier required in route' do
    let(:prefix) { "#{global_id}/" }

    before do
      allow(Gatherable.config).to receive(:prefixed_resources) { [data_table.name] }
      Gatherable::RouteDrawer.draw
    end

    it_behaves_like '#index' do
      it_behaves_like 'auth failed' do
        let(:perform_request) { Proc.new{index} }
      end
    end

    it_behaves_like '#show' do
      it_behaves_like 'auth failed' do
        let(:perform_request) { Proc.new{index} }
      end
    end

    it_behaves_like '#create' do
      it_behaves_like 'auth failed' do
        let(:perform_request) { Proc.new{ create } }
        let(:params) { {} }

        it 'does not create an object' do
          expect{perform_request.call}.to_not change{model_class.count}
        end
      end
    end

    it_behaves_like '#update' do
      it_behaves_like 'auth failed' do
        let(:perform_request) { Proc.new{ update } }
        let(:params) { {} }
        let(:instance) { model_class.new(model_name => '3.0', :session_id => global_id) }
        let!(:id) { instance.save!; instance.reload.id }

        before do
          allow(model_class).to receive(:find_by!) { instance }
        end

        it 'does not update the instance' do
          perform_request.call
          expect(instance).to eql instance.reload
        end
      end
    end

    it_behaves_like '#destroy' do
      it_behaves_like 'auth failed' do
        let(:perform_request) { Proc.new{ destroy } }
        let(:instance) { model_class.new(model_name => '3.0', :session_id => global_id) }
        let!(:id) { instance.save!; instance.reload.id }

        before do
          allow(model_class).to receive(:find_by!) { instance }
        end

        it 'does not delete the instance' do
          expect{perform_request.call}.to_not change{instance.persisted?}
        end
      end
    end
  end

  context 'unique identifier not required in route' do
    let(:prefix) { '' }

    before do
      allow(Gatherable.config).to receive(:prefixed_resources) { [] }
      Gatherable::RouteDrawer.draw
    end

    it_behaves_like '#index'
    it_behaves_like '#show'
    it_behaves_like '#create'
    it_behaves_like '#update'
    it_behaves_like '#destroy'
  end

  [:index, :show, :create, :update, :destroy].each do |disallowed_action|
    context "#{disallowed_action} not allowed" do
      let(:all_actions) { [:index, :show, :create, :update, :destroy] }
      let(:prefix) { }
      let(:params) { {} }

      before do
        allow(data_table).to receive(:allowed_controller_actions).and_return(all_actions - [disallowed_action])
        Gatherable::RouteDrawer.draw
      end

      specify "sending #{disallowed_action} raises error"  do
        expect{send(disallowed_action)}.to raise_error(ActionController::RoutingError)
      end

      after do
        allow(data_table).to receive(:allowed_controller_actions) { all_actions }
        Gatherable::RouteDrawer.draw
      end
    end
  end
end
