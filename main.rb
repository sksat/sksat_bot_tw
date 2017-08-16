#!/usr/bin/ruby
load 'client.rb'

twitter_client = TwitterClient.new

tc = twitter_client.getClient

id = ""
while true do
	tweet = tc.search("千種夜羽").first
	if tweet.id != id
		if tweet.user.id != 876273884563030018
			user = tweet.user
			str = "@sksat_tty " + user.name + "(" + user.uri + ")さんが千種夜羽についてツイートしています"
			puts str
			tc.update str
		end
	end
	id = tweet.id
	sleep 30
end
