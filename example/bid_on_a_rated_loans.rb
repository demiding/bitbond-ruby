require "pstore"
require 'bitbond'
require 'json'

db = PStore.new('db.pstore')

Bitbond.configure do |config|
  config.api_host   = 'http://www.bitbond.dev/api/v1'
  config.app_id     = '4ee9e10df5ccc51b8fa3548db3f0138389ee33037725997679eff2c15d6c7515'
  config.secret_key = 'bcfd2d07071a43d22a364febd17dacc238da83ed2980b34e211d2161ffe41dc4'
end

callback = "urn:ietf:wg:oauth:2.0:oob"
scope = 'api'

token = nil
token_hash = nil

db.transaction(true) do
  token_hash = db[:token]
end

create_client = ->(token_options = {}) {
  opts = Hash[token_options.map { |k,v| [k.to_sym, v] } ]
  opts = opts.select {|k,v| [:access_token, :refresh_token, :expires_at].include?(k) }
  Bitbond::Client.new(**opts)
}


if token_hash
  # We have a token already, refresh it and use
  puts token_hash
  client = create_client.call(token_hash)
  db.transaction do
    token = client.refresh
    db[:token] = token.to_hash
  end
else
  # We need to generate a new token
  client = create_client.call(access_token: nil)

  puts "Authorize url: \n"
  puts client.oauth_client.auth_code.authorize_url(redirect_uri: callback, scope: scope)

  puts "Input token: \n"
  authorization_token  = gets
  authorization_token  = authorization_token.delete("\n")
  puts "Authorization token: '#{authorization_token}'"

  token = client.oauth_client.auth_code.get_token(authorization_token, redirect_uri: callback)
  db.transaction do
    db[:token] = token.to_hash
  end
end

prog = ->(c) {
  puts JSON.pretty_generate(c.account(account_type: 'primary'))
  loans = c.loans(status: 'in_funding', base_currency: 'usd', rating: 'A', term: 'term_6_weeks')['loans']
  puts JSON.pretty_generate(loans)
  puts "Matching loan size: #{loans.size}."
  puts "Press y to bid on the loans, any other key to cancel"
  answer = gets.strip
  if answer == 'y'
    loans.each do |l|
      puts "Bidding on loan: #{l['code']}, amount is 0.1 BTC"
      # c.bid(loan_id: l['code'], amount: 0.1)
    end
  else
    puts "Not doing anything.."
  end
}

client = create_client.call(token.to_hash)
puts "*****************"
begin
  prog.call(client)
rescue => e
  puts "Got error when getting loans: #{e}"
end
puts "*****************"
puts "\n\n"
puts "The token is: #{token.to_hash}\n"


