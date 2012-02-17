#  qype = Qype::Client.new(Settings::Qype.credentials.key, Settings::Qype.credentials.secret, "es_ES")
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
    element :id, String
    element :updated, DateTime
    element :created, DateTime
    has_many :links, Link

    attr_accessor :children

    def real_id
      id.gsub!(/tag:api.qype.com,\d{4}-\d{2}-\d{2}:\/places\/categories\//,'')
    end

    def get_children(client, deep = false)
      return @children if @children
      link = self.links.detect {|b| b.rel == "http://schemas.qype.com/place_categories.children"}
      return @children =[] if !link

      response = client.get(link.href)
      @children = self.class.parse(response.body)
      @children.each do |cat|
        cat.get_children(client, deep)
      end if deep
      @children
    end

    def self.get_all(client, deep = false)
      return @categories if @categories
      response = client.get('/place_categories')
      @categories = self.parse(response.body)
      if deep
        @categories.each do |cat|
          cat.get_children(client, true)
        end
      end
      @categories
    end
  end

  class Image
    include HappyMapper

    tag 'image'

    attribute :small, String
    attribute :medium, String
    attribute :large, String
  end

  class Address
    include HappyMapper

    tag 'address'

    element :street, String
    element :postcode, String
    element :housenumber, String
    element :city, String
  end

  class Place
    include HappyMapper

    tag 'place'

    element :id, String
    element :title, String
    element :phone, String
    element :average_rating, Float
    element :point, String

    has_one :image, Image
    has_one :address, Address
    has_many :categories, Category
    has_many :links, Link

    def place_id
      id.gsub!(/tag:api.qype.com,\d{4}-\d{2}-\d{2}:\/places\//,'')
    end

    def reviews(client, language_code)
      link = self.links.find { |link| link.rel == 'http://schemas.qype.com/reviews' && link.hreflang == language_code }
      throw :language_not_supported if link.nil?

      response = client.get(link.href)
      Review.parse(response.body)
    end

    def self.get(client, place_id)
      response = client.get("/places/#{place_id}")
      parse(response.body, :single => true)
    end

    def self.search(client, search_term, location_name)
      response = client.get('/places', :query => { :show => search_term, :in => location_name })
      Place.parse(response.body)
    end

    # options can be
    #   :show => search_term            show places matching this search term
    #   :in_category => category_id     only show places in a specific category
    #   :order => order                 order results by: 'distance' (default), 'rating'
    #
    def self.nearby(client, latitude, longitude, options = {})
      response = client.get("/positions/#{latitude},#{longitude}/places", :query => options)
      Place.parse(response.body)
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