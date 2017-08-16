#!/usr/bin/ruby
require 'yaml'
require 'twitter'
require 'tweetstream'

class TwitterClient
	def initialize()
		@keys = YAML.load_file("secret.yml")["twitter"]
		@client = Twitter::REST::Client.new do |config|
			config.consumer_key			= @keys["CONSUMER_KEY"]
			config.consumer_secret		= @keys["CONSUMER_SECRET"]
			config.access_token			= @keys["ACCESS_TOKEN"]
			config.access_token_secret	= @keys["ACCESS_TOKEN_SECRET"]
		end
		TweetStream.configure do |config|
			config.consumer_key         = @keys["CONSUMER_KEY"]
 			config.consumer_secret      = @keys["CONSUMER_SECRET"]
 			config.oauth_token         = @keys["ACCESS_TOKEN"]
 			config.oauth_token_secret  = @keys["ACCESS_TOKEN_SECRET"]
			config.auth_method = :oauth
		end
		@stream = TweetStream::Client.new
	end

	def getClient
		return @client
	end

	def getStream
		return @stream
	end

	def tweet(str)
		@client.update(str)
	end

	def reply(status_id, str)
		@client.update(str, in_reply_to_status_id: status_id)
	end

	def search(str)
		return @client.search(str, :count => 10, :result_type => "recent")
	end
end

