#!/usr/bin/ruby

require 'yaml'
require 'twitter'

keys = YAML.load_file("secret.yml")["twitter"]

client = Twitter::REST::Client.new do |config|
	config.consumer_key			= keys["CONSUMER_KEY"]
	config.consumer_secret		= keys["CONSUMER_SECRET"]
	config.access_token			= keys["ACCESS_TOKEN"]
	config.access_token_secret	= keys["ACCESS_TOKEN_SECRET"]
end

client.owned_lists.each do |list|
	if list.name == "え"
		members = client.list_members(list.id, count: 1000)
		members.each do |user|
			puts "#{user.id} #{user.screen_name} #{user.name}"
		end
	end
end
