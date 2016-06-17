require "spec_helper"

describe Bitbond::Configuration do
  after { restore_default_config }

  describe "#app_id" do
    context "when app id configured" do
      it "is used as app id" do
        app_id = "app_id_123"
        Bitbond.configure { |config| config.app_id = app_id }

        expect(Bitbond.configuration.app_id).to eq(app_id)
      end
    end
  end

  describe "#secret_key" do
    context "when secret_key configured" do
      it "is used" do
        secret_key = "bitbond-secret-key"
        Bitbond.configure { |config| config.secret_key = secret_key }

        expect(Bitbond.configuration.secret_key).to eq(secret_key)
      end
    end
  end

  describe "#api_host" do
    context "when no api host specified" do
      it "usages the deafult host" do
        expect(
          Bitbond.configuration.api_host
        ).to eq("https://www.bitbond.com/api/v1")
      end
    end

    context "when custom api host specified" do
      it "use the custom host" do
        custom_api_host = "http://custom-api-host.example.com"
        Bitbond.configure {|config| config.api_host = custom_api_host }

        expect(Bitbond.configuration.api_host).to eq(custom_api_host)
      end
    end
  end
end
