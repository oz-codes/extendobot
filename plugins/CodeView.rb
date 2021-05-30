require 'cinch'
require 'open-uri'
require_relative '../classes/Util.rb'
class CodeView
	include Cinch::Plugin
	include Hooks::ACLHook
	include Util::PluginHelper
	set :prefix, /^:/
	@clist = %w{paste}
	@@commands["paste"] = ":paste <plugname> - output plugin source to pastebin"
	@@levelRequired = 10
	match /paste ([a-zA-Z][a-zA-Z0-9]+)/, method: :pastebin;
	
	def pastebin(m, modname) 
        response = "#{m.user.nick}: "
		if(!aclcheck(m)) 
		    response << "your access level is not high enough for this command."
		end
		path = "./plugins/#{modname}.rb"
		if(File.exist?(path)) 
          response <<  IO.popen("pastebin -f #{path} -l ruby -n '#{modname} src'").readlines.pop
		 else 
			response << "#{modname} not found..."
		end
        m.reply response
	end
end

		
	
