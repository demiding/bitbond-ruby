require "pstore"
require 'bitbond'
require 'json'

db = PStore.new('db.pstore')

app_id = ''
secret = ''
callback = "urn:ietf:wg:oauth:2.0:oob"
scope = 'api'
base_url = 'http://www.bitbond.com'


token = nil
token_hash = nil

db.transaction(true) do
  token_hash = db[:token]
end


create_client = ->(token_options = {}) {
  opts = Hash[token_options.map { |k,v| [k.to_sym, v] } ]
  opts = opts.select {|k,v| [:access_token, :refresh_token, :expires_at].include?(k) }
  Bitbond::Client.new(app_id: app_id, secret: secret, base_url: base_url, **opts)
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
  loans = c.loans(status: 'in_funding', base_currency: 'usd', rating: 'A', term: 'term_6_weeks')['loans']
  puts JSON.pretty_generate(loans)
  puts "Matching loan size: #{loans.size}."
  puts "Press y to bid on the loans, any other key to cancel"
  answer = gets.strip
  if answer == 'y'
    loans.each do |l|
      puts "Bidding on loan: #{l['code']}, amount is 0.1 BTC"
      c.bid(loan_id: l['code'], amount: 0.1)
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


