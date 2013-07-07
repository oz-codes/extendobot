require 'cinch'
require_relative '../classes/Util.rb'
class Help
	include Cinch::Plugin
	include Util::PluginHelper
	@@commands["help"] = ":help [<cmd>] - produce help for <cmd>"
	set :prefix, /^:/
	match /help (.+)?/, method: :gethelp

	def gethelp(m, mdl = nil)
		case mdl
			when nil
				m.reply("try :help <cmd> to get help for a command.")
			else
				cmds = self.class.class_eval { @@commands }
				m.reply(cmds[mdl])
		end
	end		
end
		
	
