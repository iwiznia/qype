require 'oauth/consumer'
require 'oauth/client/helper'

module HTTParty
  class Request
    private
    def configure_simple_oauth
      consumer = OAuth::Consumer.new(options[:simple_oauth][:key], options[:simple_oauth][:secret], {
        :site => "http://api.qype.com",
        #:authorize_path => "http://www.qype.com/auth_tokens/new",
        #:request_token_path => "http://api.qype.com/oauth/request_token",
        #:access_token_path => "http://api.qype.com/oauth/access_token"
      })
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

  # How to get an acess token:
  # consumer = OAuth::Consumer.new(Settings::Qype.credentials.key, Settings::Qype.credentials.secret, {:site => "http://api.qype.com/v1"})
  # request_token=consumer.get_request_token
  # request_token.authorize_url  # devuelve mal la url, en realidad es: http://www.qype.com/auth_tokens/new?oauth_token=XXXXX
  # access_token = request_token.get_access_token(:oauth_verifier=>"XXXXXXX")
  # access_token.token access_token.secret

  # Use a stored acces token:
  # access_token = OAuth::AccessToken.new(consumer, Settings::Qype.access.token, Settings::Qype.access.secret)
  #


end