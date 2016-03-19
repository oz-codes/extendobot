require 'cinch'
require 'open-uri'
require_relative '../classes/Util.rb'
class BotTools
	include Cinch::Plugin
	include Hooks::ACLHook
	include Util::PluginHelper
	set :prefix, /^:/
	@clist = %w{join part}
	@@commands["join"] = ":join <channel> - join channel"
	@@commands["part"] = ":part <channel> - part channel"
	@@levelRequired = 10
	match /join (#.+)/, method: :join;
	match /part (#.+)/, method: :part;
	
	def join(m, chan)
		aclcheck(m)
		if(!aclcheck(m)) 
			m.reply("#{m.user.nick}: " + Util::Util.instance.getExcuse())
			return
		end
		bot = Util::BotFamily.instance.get(Util::Util.instance.hton(m.bot.config.server)).bot
		idx = bot.channels.find_index { |x| x.name == chan }
	
		if(idx == nil) 
			bot.join(chan)
		else 
			m.reply "already in #{chan}"
		end
		m.reply "joined #{chan}"
	end
	def part(m, chan)
		aclcheck(m)
		if(!aclcheck(m)) 
			m.reply("#{m.user.nick}: " + Util::Util.instance.getExcuse())
			return
		end
		ibot = Util::BotFamily.instance.get(Util::Util.instance.hton(m.bot.config.server)).bot
		idx = bot.channels.find_index { |x| x.name == chan }
		if(idx != nil) 
			m.reply "parting #{chan}"
			bot.part(chan)
		else 
			m.reply "not in #{chan}"
		end
	end

end

		
	
