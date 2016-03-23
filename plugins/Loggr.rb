require 'cinch'
require 'open-uri'
require_relative '../classes/Util.rb'
class Loggr
	include Cinch::Plugin
	include Hooks::ACLHook
	include Util::PluginHelper
	listen_to :channel
	
	def listen(m)
		text = m.message
		return if m.message.match /^:/
		user = m.user.nick
		channel = m.channel.name
		puts "loggr\n\t#{user}: #{text}"
		db = Util::Util.instance.getCollection("extendobot","logs") 
		tm = Time.now.to_i
		server = Util::Util.instance.hton(m.bot.config.server)
		db.insert_one({'channel' => channel, 'user' => user, 'text' => text, 'time' => tm, 'server' => server})
	end
end
