require 'cinch'
require 'open-uri'
require_relative '../classes/Util.rb'
class DynPlug
	include Cinch::Plugin
	include Hooks::ACLHook
	include Util::PluginHelper
	set :prefix, /^:/
	@@commands["dynload"] = ":dynload <plugname> <url> - dynamically load a plugin from <url> using <plugname> as plugin name"
	@@levelRequired = 10
	match /dynload ([a-zA-Z][a-zA-Z0-9]+) (.+)/;
	
	def execute(m, modname, url) 
		aclcheck(m)
		if(!aclcheck(m)) 
			m.reply("#{m.user.nick}: your access level is not high enough for this command.")
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
		ibot = Util::BotFamily.instance.get(Util::Util.instance.hton(m.bot.config.server))
		ibot.bot.plugins.register_plugin(Object.const_get(modname))
		m.reply("#{modname} added successfully")
	end
end
		
	
