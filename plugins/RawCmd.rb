require 'cinch'
require 'open-uri'
require_relative '../classes/Util.rb'
class RawCmd
	include Cinch::Plugin
	include Hooks::ACLHook
	include Util::PluginHelper
	set :prefix, /^:/
	@clist = %w{raw eval}
	@@commands["raw"] = ":raw <cmd> - run <cmd> through terminal untouched (requires SUPER ADMIN OVER 9000 PRIVILEGES)";
	@@commands["eval"] = ":eval <rcode> - evaluate <rcode> as ruby code (requires SUPER ADMIN OVER 9000 PRIVILEGES)";
	@@levelRequired = 9001
	match /raw (.+)/, method: :raw;
	match /eval (.+)/, method: :reval;
	

	def raw(m, cmd)
		aclcheck(m)
		if(!aclcheck(m)) 
                        e = Util::Util.instance.getExcuse()
			m.reply("lolnorhx: #{e})")
			return
		end
		IO.popen(cmd).readlines.each { |line|
			m.reply line
		}
	end
	
	def reval(m, code) 
		aclcheck(m)
		if(!aclcheck(m)) 
                        e = Util::Util.instance.getExcuse()
			m.reply("lolnorhx: #{e})")
			return
		end
		m.reply(eval(code));
	end
end
