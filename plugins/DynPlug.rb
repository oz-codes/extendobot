require 'cinch'
require 'open-uri'
require_relative '../classes/Util.rb'
class DynPlug
	include Cinch::Plugin
	include Hooks::ACLHook
	set :prefix, /^:/
	@commandName = "dynload"
	@levelRequired = 10
	match /dynload ([a-zA-Z][a-zA-Z0-9]+) (.+)/;
	
	def execute(m, modname, url) 
		if(!Thread.current[:aclpass]) 
			m.reply("#{m.user.name}: your access level is not high enough for this command.")
			debug Thread.current.inspect
			return
		end
		if(File.exist?("/var/src/ruby/extendobot/plugins/#{modname}.rb")) 
			m.reply("plugin with name #{modname} already exists")
			return false;
		end
		content = ""
		open(url) do |f|
			content = f.read
			content.gsub!(%r{</?[^>]+?>}, '')
			open("/var/src/ruby/extendobot/plugins/#{modname}.rb", "w") do |plugin|
				plugin.write content
			end
		end
		require "/var/src/ruby/extendobot/plugins/#{modname}.rb";
		ibot = Util::Bot.instance
		ibot.bot.plugins.register_plugin(Object.const_get(modname))
		m.reply("#{modname} added successfully")
	end
end
		
	
