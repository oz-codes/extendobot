require 'cinch'
require_relative '../classes/Util.rb'
class Helo
	include Cinch::Plugin
	set :prefix, /^:/
	extend Hooks::ACLHook
	match /helo/;
	
	def execute(m)
		m.reply "helo #{m.user.name}" 
	end
end
		
	
