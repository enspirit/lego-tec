require 'spec_helper'

describe LegoTec::WebApp do
  include Rack::Test::Methods

  let(:app) do
    LegoTec::WebApp
  end

  it 'works' do
    get '/'
    expect(last_response).to be_ok
  end
end