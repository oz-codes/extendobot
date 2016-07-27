require 'cinch'
require 'open-uri'
require_relative '../classes/Util.rb'
class Replace
	include Cinch::Plugin
	include Hooks::ACLHook
	include Util::PluginHelper
	set :prefix, /^s/
	@clist = %w{s//}
	@@commands["s//"] = "s/<search>/<replacement>/[g] - replace <search> with <replacement> from recent messages (g is global)"
	
	match /\/(.+)\/(.+)\/(g)?/, method: :replace;
	
	def replace(m, search, replace, global=nil)
		db = Util::Util.instance.getCollection("extendobot","logs")
		res = db.find({
			"server" => Util::Util.instance.hton(m.bot.config.server),
			"text"   => /#{search}/
		}).limit(30).sort({"time" => -1})	
		out = ""
		puts "searching for re"
		p /#{search}/
		p replace
		if(res.count > 0) 
			puts "got res"
			p res
			row = res.to_a.find { |x| !x[:text].match /^s\// }
			str = ""
			out << row[:user] << ": "
			if(global != nil)
				str = row[:text].gsub(/#{search}/, replace)
			else
				str = row[:text].sub(/#{search}/, replace)
			end
			out << str
			m.reply(out)
		end
	end
end
