require 'cinch'
require_relative '../classes/Util.rb'
class Reminder
	include Cinch::Plugin
	include Util::PluginHelper
	@clist = %w{remind-me list-reminders rm-reminder}
	@@commands["remind-me"] = ":remind-me <reminder> - store <reminder>"
	@@commands["list-reminders"] = ":list-reminders - view reminders"
	@@commands["rm-reminder"] = ":rm-reminder /<regex>/<global> - removes one reminder that matches <regex> (case sensitive) (put g at the end to remove all that match)"
	set :prefix, /^:/
	match /remind-me (.+)?/, method: :remind
	match /list-reminders/, method: :list
	match /rm-reminder \/(.+)\/(g)?/, method: :remove

	def remind (m, reminder)
		db = Util::Util.instance.getCollection("extendobot","reminders")
		v = db.insert_one({"user" => m.user.name, "server" => Util::Util.instance.hton("#{m.bot.config.server}:#{m.bot.config.port}"), "timestamp" => Time.now.to_i, "content" => reminder})
		if(v)
			str = m.user.name + ' ' + Util::Util.instance.getSuccess()
		else
			str = "sTORAGE fiLAure " + Util::Util.instance.getExcuse()
		end 
		m.reply str
	end

	def list (m)
		db = Util::Util.instance.getCollection("extendobot","reminders")
		rs = db.find({"user" => m.user.name, "server" => Util::Util.instance.hton("#{m.bot.config.server}:#{m.bot.config.port}")})
		if(rs.count > 0) 
			rs.each { |res|
				m.reply(res[:timestamp].to_s << ": " << res[:content])
			}
		else
			m.reply "ain't got shyt nigguh"
		end
	end

	def remove (m, regex, global=nil)
		db = Util::Util.instance.getCollection("extendobot","reminders")
		out = []
		puts "global: #{global}"
		res = db.find({"content" => /#{regex}/, "user" => m.user.name, "server" => Util::Util.instance.hton("#{m.bot.config.server}:#{m.bot.config.port}")})
		if(global == nil) 
			res.limit(1)
			content = res.to_a[0][:content]
			out.push "reminder deleted: #{content}"
		else
			res.each { |row|
				out.push "reminder deleted: " + row[:content]
			}	
		end	
		rs = 0
		if(global == nil) 
			rs = res.delete_one
		else
			rs = res.delete_many
		end
		if(rs) then out.each { |msg| m.reply msg } end
		
	end	
end
		
	
