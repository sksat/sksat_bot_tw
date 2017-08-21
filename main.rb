#!/usr/bin/ruby
require 'date'
require 'yaml'
require 'shellwords'
load 'client.rb'

twitter_client = TwitterClient.new

tc = twitter_client.getClient
tc.update "起動中..." + DateTime.now.to_s

$t_id = 0
$yohanesu_num = 0

def load_yaml
	yml = YAML.load_file("data.yml")["data"]
	$t_id = (yml["t_id"]).to_i
	$yohanesu_num = (yml["yohanesu_num"]).to_i
	puts yml["yohanesu_num"]
end

def save_yaml
	open("data.yml", "w") do |f|
		f.puts("data:")
		f.puts("  t_id: "+$t_id.to_s)
		f.puts("  yohanesu_num: "+$yohanesu_num.to_s)
	end
end

load_yaml

stream = TweetStream::Client.new

begin
	stream.userstream{|status|
		text = status.text
		next if(text=~/^RT/)
		next if(status.user.id == 876273884563030018)
		if text.include?("千種夜羽") || text.include?("よはねす")
			tc.update(("@" + status.user.screen_name + "わたし千種夜羽！"), :in_reply_to_status_id => status.id)
		elsif text.include?("しーまぎょ")
			tc.update(("@"+status.user.screen_name + "（ヽ *ﾟ▽ﾟ*）ノわーい！ しーまぎょが泳ぐよ！ ( *ﾟ▽ﾟ* っ)З ==3"), :in_reply_to_status_id => status.id)
		elsif text.include?("asm")
			m = text.match(/asm:(.+)/)
			if m != nil
				asm = m[1]
				r_text=""
				if asm.include?("\"")
					r_text = "ざんねんでした"
				else
					r_text = %x[rasm2 "#{Shellwords.escape(asm)}"]
					if r_text == ""
						r_text = "error."
					end
				end
				tc.update(("@" + status.user.screen_name + " " + r_text), :in_reply_to_status_id => status.id)
			end
		elsif text.include?("@sksat_bot")
			tc.update(("@" + status.user.screen_name + "呼びましたか？"), :in_reply_to_status_id => status.id)
		end
	}
rescue => e
	puts e.message
	retry
end

=begin
TweetStream::Client.new.track('千種夜羽','よはねす','ヨハネス') do |status|
	next unless status.lang == "ja"
	puts "#{status.user.screen_name} #{status.text}"
end
=end

=begin
while true do
	tweet = tc.search("千種夜羽").first
	if tweet.id != $t_id
		user = tweet.user
		puts user.name,tweet.text
		if user.id != 876273884563030018
			str = "@sksat_tty "
			if user.id == 730341017736470528
				str += "わたしの名前を呼びましたね？\nちなみに" + $yohanesu_num.to_s + "回目ですよ！"
				$yohanesu_num += 1
				puts "よはねす"
			else
				str += user.name + "(" + user.uri + ")さんが千種夜羽についてツイートしています"
				puts str
			end
			tc.update(str, in_reply_to_status_id: tweet.id)
		end
	end
	$t_id = tweet.id
	save_yaml
	sleep 5
end
=end
