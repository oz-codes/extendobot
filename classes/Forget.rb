require 'cinch'
require 'open-uri'
require_relative '../classes/Util.rb'
class Forget
	include Cinch::Plugin
	include Hooks::ACLHook
	include Util::PluginHelper
	set :prefix, /^:/
	@@commands["forget"] = ":forget <plug> - 'forget' a plugin (disable <plug>)"
	@@levelRequired = 10
	match /forget ([a-zA-Z][a-zA-Z0-9]+)/;
	
	def execute(m, modname) 
		aclcheck(m)
		if(!aclcheck(m)) 
			m.reply("#{m.user.nick}: your access level is not high enough for this command.")
			return
		end
		ibot = Util::BotFamily.instance.get(Util::Util.instance.hton(m.bot.config.server)).bot
		plug = Kernel.const_get(modname)
		require "/var/src/ruby/extendobot/plugins/#{modname}.rb"
		ibot.plugins.unregister_plugin(plug)
		m.reply("#{modname} forgotten successfully")
	end
end
		
	
