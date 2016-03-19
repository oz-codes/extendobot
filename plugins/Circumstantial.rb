require 'cinch'
require_relative '../classes/Util.rb'
class Circumstantial
	include Cinch::Plugin
	include Util::PluginHelper
	@clist = %w{excuse excuse-add success success-add}
	@@commands["excuse"] = ":excuse - get a random excuse"
	@@commands["add-excuse"] = ":excuse-add <excuse> - procrastinate more, bot!"
	@@commands["success"] = ":success - get a random success message"
	@@commands["add-success"] = ":success-add <msg> - add a success message. be a community!"
	@@commands["github"] = ":github - get github url for extendobot"
	set :prefix, /^:/
	match /excuse$/, method: :excuse
	match /add-excuse (.+)/, method: :excuse_add
	match /success$/, method: :success
	match /add-success (.+)/, method: :success_add
	match /github$/, method: :github

	def github (m)
		m.reply "http://github.com/8dx/extendobot"
	end

	def excuse (m)
		m.reply(m.user.nick + ": " + Util::Util.instance.getExcuse())
	end
	def success (m)
		m.reply (m.user.nick + ": " + Util::Util.instance.getSuccess())
	end
	def excuse_add (m, exc)
		res = Util::Util.instance.addExcuse(exc)
		puts "add excuse res #{res}"
		if(res > 0) 
			puts "SUCKESS"
			success(m)
		else
			puts "failers"
			excuse(m)
		end
	end

	def success_add (m, suc)
		res = Util::Util.instance.addSuccess(suc)
		puts "add success res #{res}"
		if(res > 0)
			puts "SUCCESS!"
			success(m)
		else
			puts "FAILER!!"
			excuse(m)
		end
	end	
end
		
	
