module Qype
  class Link
    include HappyMapper

    tag 'link'

    attribute :href, String
    attribute :hreflang, String
    attribute :title, String
    attribute :rel, String
    attribute :count, Integer
  end

  class Category
    include HappyMapper

    tag 'category'

    element :title, String
    element :full_title, String
    element :qype_id, String, :tag => "id"
    element :updated, DateTime, :read_only => true
    element :created, DateTime, :read_only => true
    has_many :links, Link, :read_only => true

    attr_accessor :children

    def initialize(attrs = {})
      attrs.each do |name, val|
        self.send("#{name}=", val)
      end
    end

    def real_id
      id.gsub!(/tag:api.qype.com,\d{4}-\d{2}-\d{2}:\/places\/categories\//,'')
    end

    def get_children(deep = false)
      return @children if @children
      link = self.links.detect {|b| b.rel == "http://schemas.qype.com/place_categories.children"}
      return @children =[] if !link

      response = Client.get_client.get(link.href)
      @children = self.class.parse(response.body)
      @children.each do |cat|
        cat.get_children(Client.get_client, deep)
      end if deep
      @children
    end

    def get_all(deep = true)
      return @categories if @categories
      response = Client.get_client.get('/place_categories')
      @categories = self.parse(response.body)
      if deep
        @categories.each do |cat|
          cat.get_children(Client.get_client, true)
        end
      end
      @categories
    end
  end

  class Image
    include HappyMapper

    tag 'image'

    attribute :large, String
    attribute :medium, String
    attribute :small, String
    attribute :medium2x, String
  end

  class Asset
    include HappyMapper

    tag 'asset'

    element :qype_id, String, :tag => "id"
    element :caption, String
    element :created, DateTime

    has_one :image, Image
    has_many :links, Link
  end

  class Address
    include HappyMapper

    tag 'address'

    element :street, String
    element :postcode, String
    element :housenumber, String
    element :city, String
    element :country_code, String

    def initialize(attrs = {})
      attrs.each do |name, val|
        self.send("#{name}=", val)
      end
    end
  end

  class Place
    include HappyMapper

    tag 'place'

    element :qype_id, String, :tag => "id", :read_only => true
    element :title, String
    element :phone, String
    element :average_rating, Float, :read_only => true
    element :point, String
    element :closed, Boolean
    element :url, String
    element :owner_description, String
    element :explicit_content, Boolean
    element :created, DateTime
    element :updated, DateTime

    has_one :address, Address
    has_many :categories, Category
    has_many :links, Link, :read_only => true

    def initialize(attrs = {})
      attrs.each do |name, val|
        self.send("#{name}=", val)
      end
    end

    def real_id
      id.gsub!(/tag:api.qype.com,\d{4}-\d{2}-\d{2}:\/places\//,'')
    end

    def reviews(language_code = nil)
      @review ||= {}
      lang = (language_code || Client.class.default_params[:lang].split("_").first)
      return @review[lang] if @review[lang]
      link = self.links.find { |link| link.rel == 'http://schemas.qype.com/reviews' && link.hreflang == lang }
      throw :language_not_supported if link.nil?

      response = Client.get_client.get(link.href)
      @review[lang] = Review.parse(response.body)
    end

    def assets
      return @assets if @assets
      link = self.links.find { |link| link.rel == 'http://schemas.qype.com/assets'}
      throw :assets_not_found if link.nil?

      response = Client.get_client.get(link.href)
      @assets = Asset.parse(response.body)
    end

    def self.get(place_id)
      response = Client.get_client.get("/places/#{place_id}")
      parse(response.body, :single => true)
    end

    def self.search(search_term, location_name)
      response = Client.get_client.get('/places', :query => { :show => search_term, :in => location_name })
      self.parse(response.body)
    end

    # options can be
    #   :show => search_term            show places matching this search term
    #   :in_category => category_id     only show places in a specific category
    #   :order => order                 order results by: 'distance' (default), 'rating'
    #
    def self.nearby(latitude, longitude, options = {})
      response = Client.get_client.get("/positions/#{latitude},#{longitude}/places", :query => options)
      self.parse(response.body)
    end

    def save
      Client.get_access_token.post("/v1/places", self.to_xml)
    end
  end

  class Tag
    include HappyMapper

    tag 'tag'

    attribute :term, String
  end

  class Review
    include HappyMapper

    tag 'review'

    element :rating, Integer
    element :language, String
    element :content, String, :tag => "content[@type='text']"
    element :formatted_content, String, :tag => "content[@type='xhtml']"

    has_many :tags, Tag
    has_many :links, Link
  end
end