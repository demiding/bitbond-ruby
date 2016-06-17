module Bitbond
  class Configuration
    attr_accessor :app_id, :secret_key, :api_host

    def initialize
      @api_host ||= "https://www.bitbond.com/api/v1"
    end
  end

  def self.configure
    yield configuration
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configuration=(config)
    @configuration = config
  end
end
