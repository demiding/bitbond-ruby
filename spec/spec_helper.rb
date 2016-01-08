require 'bundler/setup'
require 'webmock/rspec'
Bundler.setup

require 'bitbond'

def app_id
  'APP_ID'
end

def secret
  'SECRET'
end

def access_token
  'ACCESS_TOKEN'
end

def bitbond_client
  Bitbond::Client.new(app_id: app_id, secret: secret, access_token: access_token)
end

def base_url
  "https://www.bitbond.com/api"
end

def mock_item
  { 'key1' => 'val1', 'key2' => 'val2' }
end

def mock_collection
  [ mock_item, mock_item ]
end

def api_url(endpoint)
  "#{base_url}/#{endpoint}"
end

def mock_json_collection
  { body: mock_collection.to_json, headers: {'Content-Type'=>'application/json'} }
end

def mock_json_item
  { body: mock_item.to_json, headers: {'Content-Type'=>'application/json'} }
end


def test_get_item(client, endpoint, method, id)
  url = api_url(endpoint + "/#{id}")
  stub_request(:get, url)
    .to_return(body: mock_item.to_json, headers: {'Content-Type' => 'application/json'})

  expect(client.public_send(method.to_sym, id)).to eq mock_item
  expect(a_request(:get, url)).to have_been_made
end

def test_get_collection(client, endpoint, method = endpoint)
  url = api_url(endpoint)
  stub_request(:get, url)
    .to_return(body: mock_collection.to_json, headers: {'Content-Type' => 'application/json'})

  expect(client.public_send(method)).to eq mock_collection
  expect(a_request(:get, url)).to have_been_made
end


