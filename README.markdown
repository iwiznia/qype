Qype API
--------

The official Ruby library for interacting with the Qype API.


Installation
------------

install required gems:

    sudo gem install oauth
    sudo gem install happymapper
    sudo gem install httparty

Usage
-----

    require 'rubygems'
    require 'qype'
    
    qype = Qype::Client.new('your_api_key', 'your_api_secret', 'your_lang')
    places = qype.search_places('sushi', 'Hamburg')
