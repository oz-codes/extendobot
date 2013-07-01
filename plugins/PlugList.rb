require 'cinch'
require_relative '../classes/Util.rb'
class PlugList
	include Cinch::Plugin
	@@commandName = "plugs"
	set :prefix, /^:/
	match /plugs/

	def execute(m) 
		ibot = Util::Bot.instance
		str = ""
		ibot.bot.plugins.each do |plug|
			str += " #{plug.class.name}"
		end
		m.reply str
	end
end
		
	
