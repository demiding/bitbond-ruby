require "pstore"
require 'bitbond'

db = PStore.new('db.pstore')

app_id = '0dd52a22cde94dc1ee59b3dc41223801948b6477d301f7312c2cdcc9844db83f'
secret = 'fee79b9efb1e208348731708b3bbbdc1036d7c3f358a9e85695b4ef0a27cedcd'
callback = "urn:ietf:wg:oauth:2.0:oob"
scope = 'api'


token = nil
token_hash = nil

db.transaction(true) do
  token_hash = db[:token]
end

create_client = ->(token_options = {}) {
  opts = Hash[token_options.map { |k,v| [k.to_sym, v] } ].select {|k,v| [:access_token, :refresh_token, :expires_at].include?(k) }
  Bitbond::Client.new(app_id: app_id, secret: secret, base_url: "http://www.bitbond.dev/", **opts)
}


if token_hash
  # token = OAuth2::AccessToken.from_hash(client, token_hash)
  puts token_hash
  client = create_client.call(token_hash)
  db.transaction do
    token = client.refresh
    db[:token] = token.to_hash
  end
else
  client = create_client.call(access_token: nil)

  puts "(Authorize url) Open url in your browser: \n"
  puts client.oauth_client.auth_code.authorize_url(redirect_uri: callback, scope: scope)

  puts "(Authorization token) Copy and paste the authorization token: \n"
  authorization_token  = gets
  authorization_token  = authorization_token.delete("\n")
  puts "Using authorization token: '#{authorization_token}'"

  token = client.oauth_client.auth_code.get_token(authorization_token, redirect_uri: callback)
  db.transaction do
    db[:token] = token.to_hash
  end
end

client = create_client.call(token.to_hash)
puts "*****************"
begin
  puts client.loans
rescue => e
  puts "Got error when getting loans: #{e.response}"
end
puts "*****************"
puts "\n\n"
puts "The token is: #{token.to_hash}\n"

