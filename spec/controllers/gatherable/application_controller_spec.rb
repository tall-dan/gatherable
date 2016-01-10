require 'rails_helper'
describe 'Gatherable::PricesController' do
  before(:all) do
    @controller = Gatherable::PricesController.new
  end

  let(:json_response) { JSON.parse(response.body) }
  describe '#create', :type => :request do
    def do_post(params)
      post "/gatherable/session_id123/prices.json", params
    end

    shared_examples 'successful object creation' do
      before do
        model_params.merge!('session_id' => 'session_id123')
      end

      it 'creates an object' do
        expect(Gatherable::Price).to receive(:create!).with(model_params)
        do_post({:price => model_params })
      end

      it "contains all attributes of the model" do
        allow(Gatherable::Price).to receive(:create!).with(model_params).and_return(price)
        do_post(passed_params)
        Gatherable::Price.column_names.each do |attr|
          expect(json_response.keys).to include(attr)
        end
      end

      it "returns the saved values created model" do
        allow(Gatherable::Price).to receive(:create!).with(model_params).and_return(price)
        do_post(passed_params)
        Gatherable::Price.column_names.each do |attr|
          expect(json_response[attr]).to eql model_params[attr]
        end
      end

      specify 'the object created is valid' do
        allow(Gatherable::Price).to receive(:create!).with(model_params).and_return(price)
        do_post(passed_params)
        expect(price).to be_valid
      end

      specify 'status is 201' do
        allow(Gatherable::Price).to receive(:create!).with(model_params).and_return(price)
        do_post(passed_params)
        expect(response.status).to eql 201
      end
    end

    context 'correct param format' do
      let(:model_params) { { "price" => "3.0"} }
      let(:passed_params) { {:price => model_params} }
      let(:price) { Gatherable::Price.new(model_params.merge(:session_id => 'session_id123')) }
      it_behaves_like 'successful object creation'
    end

    context 'auth_method set' do
      let(:model_params) { { "price" => "3.0"} }
      let(:passed_params) { {:price => model_params} }
      context 'session identifier matches passed identifier' do
        before do
          allow(Gatherable.config).to receive(:auth_method) { :session }
          session[:session_id] = 'session_id123'
          allow_any_instance_of(@controller.class).to receive(:session) { session } #boo any_instance
        end
        let(:price) { Gatherable::Price.new(model_params.merge(:session_id => 'session_id123')) }
        it_behaves_like 'successful object creation'
      end

      context 'session identifier does not match passed identifier' do
        before do
          allow(Gatherable.config).to receive(:auth_method) { :session }
          do_post(passed_params)
        end

        it 'returns an empty response body' do
          expect(response.body).to be_empty
        end

        it 'gives an unauthorized response status' do
          expect(response.status).to eql 401
        end

        it 'does not create an object' do
          expect(Gatherable::Price).to_not receive(:create!)
          do_post(passed_params)
        end
      end
    end

    context 'incorrect param format' do
      context 'required params not given' do
        specify 'the response status is 422' do
          do_post( { :yolo => 'swag' } )
          expect(response.status).to eql 422
        end
      end

      context 'required params + junk params given' do
        let(:model_params) { { "price" => "3.0"} }
        let(:junk_params) { { 'yolo' => 'swag' } }
        let(:passed_params) { {:price => model_params.merge(junk_params)}.merge(junk_params) }
        let(:price) { Gatherable::Price.new(model_params.merge(:session_id => 'session_id123')) }
        it_behaves_like 'successful object creation'
      end
    end
  end

  describe '#show', :type => :request do
    let(:price) { Gatherable::Price.new(:price => 3.0) }

    before do
      allow(Gatherable::Price).to receive(:find_by!).with(:price_id => '1', :session_id => 'session_id123').and_return(price)
      allow(Gatherable::Price).to receive(:find_by!).with(:price_id => '0', :session_id => 'session_id123').and_raise(ActiveRecord::RecordNotFound)
    end

    def do_get(price_id)
      get "/gatherable/session_id123/prices/#{price_id}.json"
    end

    context 'record found' do
      before do
        do_get(1)
      end

      it 'returns the record' do
        expect(json_response).to eql \
        ({"price_id"=>nil, "price"=>"3.0", "session_id" => nil, "created_at"=>nil, "updated_at"=>nil})
      end

      specify 'the response code is 302' do
        expect(response.status).to eql 302
      end
    end

    context 'record not found' do
      before do
        do_get(0)
      end
      specify 'the response code is 404' do
        expect(response.status).to eql 404
      end

      it 'returns errors' do
        expect(json_response).to eql({"errors"=>"ActiveRecord::RecordNotFound"})
      end
    end
  end
end
