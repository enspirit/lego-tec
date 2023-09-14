require 'spec_helper'

describe LegoTec::WebApp do
  include Rack::Test::Methods

  let(:app) do
    LegoTec::WebApp
  end

  it 'serves bus lines' do
    get '/'
    expect(last_response).to be_ok
  end

  it 'serves matrices' do
    get '/matrices-de-mobilite'
    expect(last_response).to be_ok
  end

  it 'serves statics' do
    get '/index.css'
    expect(last_response).to be_ok
  end
end
