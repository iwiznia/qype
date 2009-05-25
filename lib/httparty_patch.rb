require 'oauth/consumer'
require 'oauth/client/helper'

module HTTParty
  class Request
    private
    def configure_simple_oauth
      consumer = OAuth::Consumer.new(options[:simple_oauth][:key], options[:simple_oauth][:secret])
      oauth_options = { :request_uri => uri,
                        :consumer => consumer,
                        :token => nil,
                        :scheme => 'header',
                        :signature_method => options[:simple_oauth][:method],
                        :nonce => nil,
                        :timestamp => nil }
      @raw_request['authorization'] = OAuth::Client::Helper.new(@raw_request, oauth_options).header
    end

    alias_method :setup_raw_request_without_oauth, :setup_raw_request
    def setup_raw_request
      setup_raw_request_without_oauth
      configure_simple_oauth if options[:simple_oauth]
    end
  end
end