require 'spec_helper'

describe Bitbond::Client do

  subject(:client) {
    bitbond_client
  }

  it 'exists' do
    expect(client).to be
  end

  describe 'Investments' do
    it 'can display investments' do
      url = api_url "investments"

      stub_request(:get, url).to_return(mock_json_collection)

      expect( client.investments() ).to eq(mock_collection)

      expect(a_request(:get, url)).to have_been_made
    end

    it 'can filter by base currency' do
      url = api_url "investments"

      stub_request(:get, url).with(query: {base_currency: ['usd']}).to_return(mock_json_collection)

      expect( client.investments(base_currency: ['usd']) ).to eq(mock_collection)

      expect(a_request(:get, url).with(query: {base_currency: ['usd']} )).to have_been_made
    end

    it 'can display investment details' do
      url = api_url "investments/INVESTMENT_ID"

      stub_request(:get, url).to_return(mock_json_item)

      expect(client.investment(investment_id: 'INVESTMENT_ID')).to eq(mock_item)

      expect(a_request(:get, url)).to have_been_made
    end
  end


  describe 'Profiles' do
    it 'can display profile information' do
      url = api_url "profiles/PROFILE_ID"

      stub_request(:get, url).to_return(mock_json_item)

      expect(client.profile(profile_id: 'PROFILE_ID')).to eq(mock_item)
      expect(a_request(:get, url)).to have_been_made
    end
  end


  describe 'Accounts' do

    it 'can display information for primary account' do
      url = api_url "accounts/primary"

      stub_request(:get, url).to_return(mock_json_item)

      expect(client.account).to eq(mock_item)
      expect(a_request(:get, url)).to have_been_made

    end

    it 'can display information for auto-invest account' do
      url = api_url "accounts/auto_invest"

      stub_request(:get, url).to_return(mock_json_item)

      expect(client.account(account_type: 'auto_invest')).to eq(mock_item)
      expect(a_request(:get, url)).to have_been_made
    end

  end

  describe 'Loans' do

    it 'can display information about loans' do
      url = api_url "loans?page=0"

      stub_request(:get, url).to_return(mock_json_collection)

      expect(client.loans).to eq(mock_collection)
      expect(a_request(:get, url)).to have_been_made
    end

    it 'can filter loans by status' do
      url = api_url "loans"

      stub_request(:get, url).with(query: { status: ['funded'], page: 0 } ).to_return(mock_json_collection)

      expect(client.loans(status: ['funded'])).to eq(mock_collection)
      expect(a_request(:get, url).with(query: { status: ['funded'], page: 0})).to have_been_made
    end

    it 'can search loans' do
      stub_request(:get, "#{base_url}/loans?base_currency%5B%5D=usd&page=0&rating%5B%5D=A")
        .to_return(mock_json_collection)

      client.loans(base_currency: ['usd'], rating: ['A'])
    end

    it 'can search for term and accepts page arguments' do
      stub_request(:get, "#{base_url}/loans?base_currency%5B%5D=btc&base_currency%5B%5D=usd&page=2&term%5B%5D=term_6_weeks")
        .to_return(mock_json_collection)

      client.loans(base_currency: ['usd', 'btc'], page: 2, term: ['term_6_weeks'])
    end

    it 'can show loan detais' do
      url = api_url "loans/LOAN_ID"

      stub_request(:get, url).to_return(mock_json_item)

      expect(client.loan(loan_id: 'LOAN_ID')).to eq(mock_item)
      expect(a_request(:get, url)).to have_been_made
    end

    it 'can bid on a loan' do
      url = "#{base_url}/loans/LOAN_ID/bids"
      stub_request(:post, url).with(body: { bid: { amount: 0.1 }})

      client.bid(loan_id: "LOAN_ID", amount: 0.1)

      expect(a_request(:post, url)).to have_been_made
    end

  end

  describe 'Webhooks' do
    it 'it can list the webhooks' do
      url = api_url "webhooks"

      stub_request(:get, url).to_return(mock_json_collection)

      expect(client.webhooks).to eq(mock_collection)
      expect(a_request(:get, url)).to have_been_made
    end

    it 'can create a new webhook' do
      url = api_url "webhooks"
      stub_request(:post, url).with(body: { webhook: { callback_url: 'https://www.test.com/callback?secret=xyz' }})

      client.create_webhook(callback_url: 'https://www.test.com/callback?secret=xyz')

      expect(a_request(:post, url)).to have_been_made
    end

    it 'can delete a webhook' do
      url = api_url "webhooks/WEBHOOK_ID"
      stub_request(:delete, url)

      client.delete_webhook(webhook_id: 'WEBHOOK_ID')

      expect(a_request(:delete, url)).to have_been_made
    end

  end


  describe 'Refresh token' do
    subject(:client) {
      Bitbond::Client.new(app_id: app_id, secret: secret, access_token: access_token, **{ refresh_token: 'REFRESH' } )
    }

    it 'will be able to refresh the oauth token' do
      stub_request(:post, "https://www.bitbond.com/oauth/token").
        with(:body => {"client_id"=>"APP_ID", "client_secret"=>"SECRET", "grant_type"=>"refresh_token", "refresh_token"=>"REFRESH"}).
         to_return(:status => 200, :body => '{"access_token": "NEW_TOKEN", "refresh_token": "NEW_REFRESH_TOKEN"}', headers: {'Content-Type'=>'application/json'})

      new_token = client.refresh

      expect(new_token.token).to eq("NEW_TOKEN")
      expect(new_token.refresh_token).to eq("NEW_REFRESH_TOKEN")
    end
  end


end
