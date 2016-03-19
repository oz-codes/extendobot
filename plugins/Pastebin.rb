require 'cinch'
require 'open-uri'
require_relative '../classes/Util.rb'
class Pastebin
	include Cinch::Plugin
	include Hooks::ACLHook
	include Util::PluginHelper
	set :prefix, /^:/
	@clist = %w{paste}
	@@commands["paste"] = ":paste <plugname> - output plugin source to pastebin"
	@@levelRequired = 10
	match /paste ([a-zA-Z][a-zA-Z0-9]+)/, method: :pastebin;
	
	def pastebin(m, modname) 
		aclcheck(m)
		if(!aclcheck(m)) 
			m.reply("#{m.user.nick}: your access level is not high enough for this command.")
			return
		end
		path = "/var/src/ruby/extendobot/plugins/#{modname}.rb"
		if(File.exist?(path)) 
			IO.popen("pastebin -f #{path} -l ruby -n '#{modname} src'").readlines.each { |line| m.reply line }
		 else 
			m.reply("#{modname} not found...")
		end
	end
end

		
	
