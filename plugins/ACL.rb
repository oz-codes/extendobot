require 'cinch'
require 'open-uri'
require_relative '../classes/Util.rb'
class ACL
	include Cinch::Plugin
	include Hooks::ACLHook
	include Util::PluginHelper
	include Util::ACLHelper
	set :prefix, /^:/
	@clist = %w{acl-get acl-ls acl-add acl-rm acl-mod}
	@@commands["acl-get"] = ":acl-get <user> - get acl level for <user>"
	@@commands["acl-ls"] = ":acl-ls - list acl settings"
	@@commands["acl-add"] = ":acl-add <user> <level> - add <user> with acl <level>"
	@@commands["acl-rm"] = ":acl-rm <user> - revoke <user>'s acl"
	@@commands["acl-mod"] = ":acl-mod <user> <level> - set <user>'s acl to <level>"
	@@levelRequired = 100
	match /acl-get (.+)/, method: :aclget;
	match /acl-ls/, method: :aclls;
	match /acl-add (.+) (\d+)/, method: :acladd;
	match /acl-rm (.+)/, method: :aclrm;
	match /acl-mod (.+) (\d+)/, method: :aclmod;
	
	def aclget(m, username) 
		aclcheck(m)
		if(!aclcheck(m)) 
			m.reply("#{m.user.nick}: your access level is not high enough for this command.")
			return
		end
		get_acl(m,username)
	end

	def aclls(m) 
		list_acl(m)
	end

	def acladd(m, username, level) 
		aclcheck(m)
		if(!aclcheck(m)) 
			m.reply("#{m.user.nick}: your access level is not high enough for this command.")
			return
		end
		add_acl(m,username,level)
	end

	def aclrm(m, username) 
		aclcheck(m)
		if(!aclcheck(m)) 
			m.reply("#{m.user.nick}: your access level is not high enough for this command.")
			return
		end
		rm_acl(m,username)
	end

	def aclmod(m, username, level) 
		aclcheck(m)
		if(!aclcheck(m)) 
			m.reply("#{m.user.nick}: your access level is not high enough for this command.")
			return
		end
		set_acl(m,username,level)
	end
end
