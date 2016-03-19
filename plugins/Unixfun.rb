require 'cinch'
require 'shellwords'
require_relative '../classes/Util.rb'
class Unixfun
	include Cinch::Plugin
	include Util::PluginHelper
	set :prefix, /^:/
	@clist = %w{fortune figlet cowsay}
	@@commands["fortune"] = ":fortune(s): *nix fortunes"
	@@commands["figlet"] = ":figlet <string>: invoke figlet with string"
	@@commands["cowsay"] = ":cowsay <string>: invoke cowsay with string"
	match /fortunes?/, method: :fortune;
	match /cowsay (.+)/, method: :cowsay;
	match /figlet (.+)/, method: :figlet;
	def fortune(m)
		do_proc(m,'fortune')
	end
	def cowsay(m, str) 
		puts "cowsay #{str.shellescape}"
		do_proc(m,'cowsay ' + str.shellescape)
	end
	def figlet(m, str)
		puts "figlet #{str.shellescape}"
		do_proc(m,'figlet ' + str.shellescape)
	end	
	def do_proc(m,name)
		output = IO.popen(name)
		output.readlines.each { |line| 
			m.reply line
		}			
	end
end
