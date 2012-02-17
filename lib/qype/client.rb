module Qype
  class Client
    include HTTParty
    base_uri 'api.qype.com/v1'

    def initialize(api_key, api_secret, language = nil, base_uri = nil)
      self.class.default_options[:simple_oauth] = { :key => api_key, :secret => api_secret, :method => 'HMAC-SHA1' }
      self.class.default_params :lang => language if language
      self.class.base_uri(base_uri) if base_uri
    end

    def get(path, options = {})
      self.class.get(path, options)
    end

    def search_places(search_term, location_name)
      Place.search(self, search_term, location_name)
    end

    def nearby_places(latitude, longitude, options = {})
      Place.nearby(self, latitude, longitude, options)
    end

    def get_place(place_id)
      Place.get(self, place_id)
    end

    def get_categories(deep = true)
      Category.get_all(self, deep)
    end
  end
end
