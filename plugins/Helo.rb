require 'cinch'
require_relative '../classes/Util.rb'
class Helo
	include Cinch::Plugin
	include Util::PluginHelper
	set :prefix, /^:/
	@clist = %w{helo}
	@@commands["helo"] = ":helo - say helo"
	match /helo/;
	
	def execute(m)
		m.reply "helo #{m.user.name}" 
	end
end
		
	
