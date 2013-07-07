require 'cinch'
require_relative '../classes/Util.rb'
class Helo
	include Cinch::Plugin
	include Util::PluginHelper
	set :prefix, /^:/
	@@commands["helo"] = ":helo - say hi!"
	match /helo/;
	
	def execute(m)
		m.reply "helo #{m.user.name}" 
	end
end
		
	
