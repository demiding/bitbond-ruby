require 'oauth2'
require "bitbond/configuration"

module Bitbond
  class Client

    attr_accessor :token, :refresh_token, :expires_at

    def initialize(access_token:, refresh_token: nil, expires_at: nil)
      self.token = access_token
      self.refresh_token = refresh_token
      self.expires_at = expires_at
    end


    def investments(base_currency: [], rating: [], term: [], status: [])
      get "investments", {
        status: Array(status),
        base_currency: Array(base_currency),
        rating: Array(rating),
        term: Array(term)
      }
    end

    def investment(investment_id: )
      require_param :investment_id, investment_id
      get "investments/#{investment_id}"
    end

    def profile(profile_id:)
      require_param :profile_id, profile_id
      get "profiles/#{profile_id}"
    end

    def account(account_type: 'primary')
      require_param :account_type, account_type
      get "accounts/#{account_type}"
    end

    def loans(status: [], base_currency: [], rating: [], term: [], page: 0)
      get "loans", {
        status: Array(status),
        base_currency: Array(base_currency),
        rating: Array(rating),
        term: Array(term),
        page: page
      }
    end

    def loan(loan_id: )
      require_param :loan_id, loan_id
      get "loans/#{loan_id}"
    end

    def bid(loan_id:, amount:)
      require_param :loan_id, loan_id
      require_param :amount, amount
      post "loans/#{loan_id}/bids", { bid: { amount: amount } }
    end

    def webhooks
      get 'webhooks'
    end

    def create_webhook(callback_url: )
      require_param :callback_url, callback_url
      post 'webhooks', { webhook: { callback_url: callback_url }}
    end

    def delete_webhook(webhook_id:)
      require_param :webhook_id, webhook_id
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
      [Bitbond.configuration.api_host, endpoint].join("/")
    end

    def oauth_client
      @oauth_client ||= OAuth2::Client.new(
        Bitbond.configuration.app_id,
        Bitbond.configuration.secret_key,
        site: Bitbond.configuration.api_host
      )
    end

    def access_token
      @access_token ||= OAuth2::AccessToken.new(oauth_client, token, refresh_token: refresh_token, expires_at: expires_at)
    end

    def refresh
      access_token.refresh!
    end

    private

    def require_param(symbol, val)
      # this is taken from the implementation of rails: blank?
      if val.respond_to?(:empty?) ? !!val.empty? : !val
        raise ArgumentError, "Expected #{symbol} to be present, got: '#{val}'"
      end
    end

  end
end
