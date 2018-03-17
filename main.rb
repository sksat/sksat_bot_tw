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

stream.on_error do |msg|
	puts msg
end

stream.on_direct_message do |dm|
	puts dm.text
end

stream.on_event(:favorite) do |fav|
	#p fav
	#tc.update("fav", :in_reply_to_status_id => fav[:target_object][:id])
end

stream.on_event(:follow) do |follow|
	#p follow
	if(follow[:target][:id] == 876273884563030018)
		msg = "followed by "+follow[:source][:name]+"( @"+follow[:source][:screen_name]+" )"
		puts msg
		tc.update msg
		tc.follow follow[:source][:id]
	end
end

stream.on_timeline_status do |status|
	text = status.text
	user = status.user
	next if(text=~/^RT/)
	next if(user.id == 876273884563030018)
	if text.include?("千種夜羽") || text.include?("よはねす") || text.include?("ヨハネス") || text.include?("yohanesu")
		msg = "はーい，霞くんと明日葉ちゃんの大好きなお母さん，正義のヨハネスさんですよ〜"
		if(user.id == 730341017736470528)
			$yohanesu_num+=1
			save_yaml
			msg += "\nちなみにわたしの名前を呼んだのは"+$yohanesu_num.to_s+"回目ですね．"
		end
		tc.update(("@" + user.screen_name + msg), :in_reply_to_status_id => status.id)
	elsif text.include?("しーまぎょ")
		tc.update(("@"+user.screen_name + "（ヽ *ﾟ▽ﾟ*）ノわーい！ しーまぎょが泳ぐよ！ ( *ﾟ▽ﾟ* っ)З ==3"), :in_reply_to_status_id => status.id)
	elsif text.include?("asm")
		m = text.match(/asm:(.+)/)
		if m != nil
			asm = m[1]
			r_text=""
			if asm.include?("\"")
				r_text = "ざんねんでした"
			else
				r_text = %x[rasm2 #{Shellwords.escape(asm)}]
				if r_text == ""
					r_text = "error."
				end
			end
			tc.update(("@" + status.user.screen_name + " " + r_text), :in_reply_to_status_id => status.id)
		end
	elsif (((text == "334") || (text == "1333")) || (text == "1640"))
		msg = ""
		now = Time.now
		ts = ((status.id >> 22)+1288834974657)/1000.0
		hour = 0
		min  = 0
		if text == "334"
			hour = 3
			min  = 34
		elsif text == "1333"
			hour = 13
			min  = 33
		elsif text == "1640"
			hour = 16
			min  = 40
		else
			msg += "error!"
		end
		ans = Time.local(now.year, now.month, now.day, hour, min, 0, "JST")
		p ans
		#ts = 1508733180 + 1.33333
		delay = ts - ans.to_i
		msg += Time.at(ts).strftime("%H:%M:%S.%L")
		msg += "\n" + delay.round(3).to_s + "秒遅延"
		if(delay/60 > 15)
			msg = "お話になりません"
		end
		tc.update(("@"+user.screen_name+" "+msg), :in_reply_to_status_id => status.id)
	elsif (text.include?("あけまして") || text.include?("あけおめ"))
		now = Time.now
		ts = ((status.id >> 22)+1288834974657)/1000.0
		ans = Time.local(2018, 1, 1, 0, 0, 0, "JST")
		delay = ts - ans.to_i
		msg = ""
		if(delay < 0)
			msg = "気が早いですね．まだ2017年ですよ．"
		else
			msg = "あけましておめでとうございます！\n"
			msg += Time.at(ts).strftime("%H:%M:%S.")
			msg += ((delay - delay.to_i).round(5)*100000).to_i.to_s
			msg += "\n"
			msg += "2018年になってから"
			msg += delay.round(5).to_s + "秒経過しました！"
		end
		tc.update(("@"+user.screen_name+" "+msg), :in_reply_to_status_id => status.id)
	elsif text.include?("@sksat_bot")
		tc.update(("@" + status.user.screen_name + "呼びましたか？"), :in_reply_to_status_id => status.id)
	end
end

stream.userstream

