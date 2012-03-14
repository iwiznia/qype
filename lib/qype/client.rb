module Qype
  class Client
    include HTTParty
    base_uri 'api.qype.com/v1'

    def self.config=(conf)
      @config = conf
    end

    def self.config
      @config
    end

    def self.get_client
      raise "Credentials must be supplied. Use Qype::Client.config = {:credentials => {:key => '', :secret => ''}}" if !self.config[:credentials][:key] || !self.config[:credentials][:secret]
      @client ||= self.new(self.config[:credentials][:key], self.config[:credentials][:secret], self.config[:language])
    end

    def self.get_access_token(token = nil, secret = nil)
      return @access_token if @access_token
      consumer = OAuth::Consumer.new(@config.credentials.key, @config.credentials.secret, {:site => "http://api.qype.com/v1"})
      @access_token = OAuth::AccessToken.new(consumer, token || @config.access.token, secret || @config.access.secret)
    end

    def initialize(api_key, api_secret, language = nil, base_uri = nil)
      self.class.default_options[:simple_oauth] = { :key => api_key, :secret => api_secret, :method => 'HMAC-SHA1' }
      self.class.default_params :lang => language if language
      self.class.base_uri(base_uri) if base_uri
    end

    def get(path, options = {})
      self.class.get(path, options)
    end

    def post(path, data = "")
      self.class.post(path, :body => data)
    end

    def put(path, data = "")
      self.class.put(path, :body => data)
    end
  end
end
