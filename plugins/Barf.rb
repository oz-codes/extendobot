require 'cinch'
require_relative '../classes/Util.rb'
class Barf
	include Cinch::Plugin
	include Util::PluginHelper
	set :prefix, /^:/
	@clist = ["barf"]
	@@commands["barf"] = ":barf <user>: barfs on <user>"
	match /barf( .+)?/, method: :barf;
	
	def barf(m, user = nil)
		target = ""
		case user
			when nil
				target = m.user
			else
				target = user.strip
		end
		m.action_reply "barfs on #{target}" 
	end
end
