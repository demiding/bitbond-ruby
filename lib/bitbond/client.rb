require 'oauth2'

module Bitbond
  class Client

    attr_accessor :app_id, :secret, :token, :base_url

    def initialize( app_id:, secret:, token:, base_url: "https://www.bitbond.com")
      self.app_id = app_id
      self.secret = secret
      self.token = token
      self.base_url = base_url
    end


    def listings( base_currency: [], rating: [], term: [], page: 0)

      get 'listings', { base_currency: Array(base_currency),
                        rating: Array(rating),
                        term: Array(term),
                        page: page }
    end

    def listing(listing_id:)
      get "listings/#{listing_id}"
    end

    def bid(listing_id:, amount:)
      post "listings/#{listing_id}/bids", { bid: { amount: amount } }
    end

    def listing_comments(listing_id: )
      get "listings/#{listing_id}/comments"
    end

    def investments(base_currency: [])
      get "investments", { base_currency: Array(base_currency)}
    end

    def investment(investment_id: )
      get "investments/#{investment_id}"
    end

    def profile(profile_id:)
      get "profiles/#{profile_id}"
    end

    def profile_loans(profile_id:)
      get "profiles/#{profile_id}/loans"
    end

    def profile_investments(profile_id:)
      get "profiles/#{profile_id}/investments"
    end

    def account(account_type: 'primary')
      get "accounts/#{account_type}"
    end

    def loans(status: [])
      get "loans", {status: Array(status) }
    end

    def loan(loan_id: )
      get "loans/#{loan_id}"
    end

    def webhooks
      get 'webhooks'
    end

    def create_webhook(callback_url: )
      post 'webhooks', { webhook: { callback_url: callback_url }}
    end

    def delete_webhook(webhook_id:)
      delete "webhooks/#{webhook_id}"
    end

    def get( endpoint, params = {})
      result = access_token.get( url(endpoint), { params: params } )
      result.parsed
    end

    def post( endpoint, params = {})
      result = access_token.post( url(endpoint), { body: params.to_json, headers: {'Content-Type' => 'application/json'}})
      result.parsed
    end

    def delete(endpoint)
      access_token.delete(url(endpoint))
    end

    def url(endpoint)
      "#{self.base_url}/api/v1/#{endpoint}"
    end


    def oauth_client
      @oauth_client ||= OAuth2::Client.new(app_id, secret, site: base_url)
    end

    def access_token
      @access_token ||= OAuth2::AccessToken.new(oauth_client, token)
    end

  end
end
