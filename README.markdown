Qype API
--------

The unofficial Ruby library for interacting with the Qype API.


Installation
------------

Add this line to your gemfile:
  gem 'qype', :git => 'git://github.com/iwiznia/qype.git'


Configuration
-------------

  Qype::Client.config = {:credentials => {:key => "YOURAPIKEY", :secret => "YOURAPISECRET"}, :language => "YOURLANGUAGE"}

Usage
-----

  Qype::Client.get_client.get("/relative_url_to_qype_resource")
  Qype::Category.get_all
  Qype::Place.get("PLACEID")
  Qype::Place.search('sushi', 'Hamburg')
  Qype::Place.nearby(lat, lng, opts)