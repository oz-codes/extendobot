require 'cinch'
require_relative '../classes/Util.rb'
class Voteage
	include Util::PluginHelper
	include Cinch::Plugin
	@clist = %w{-- ++ score}
	set :prefix, /^:/
	@@commands["++"] = "(user)++ - upvote user"
	@@commands["--"] = "(user)-- - downvote user"
	@@commands["score"] = ":score <user> - get user score"
	match /score (.+)/, method: :score

	listen_to :channel
	
	def listen(m)
		if(match = /(.+)(\+\+|--)/.match(m.message))
			db = Util::Util.instance.getCollection("extendobot","votes")
			val = 0
			case match[2]
				when "++"
					val = 1
				when "--"
					val = -1
			end
			db.insert_one({
				"user" => match[1], 
				"server" => Util::Util.instance.hton("#{m.bot.config.server}:#{m.bot.config.port}"),
				"voter" => m.user.nick,
				"value" => val
			})
		end
	end
	
	def score (m, user)
		user.strip!
		score = 0
		db = Util::Util.instance.getCollection("extendobot","votes")
		server = Util::Util.instance.hton("#{m.bot.config.server}:#{m.bot.config.port}")
		puts "finding votes for #{user} on #{server}"
		res = db.find({"user" => user, "server" => server})
		if(res.count > 0)
			puts "got results for #{user}"
			res.each { |row|
				puts "got result"
				p row
				score += row[:value].to_i
			}
		else
			puts "no results so sad"
		end
		m.reply "#{user} total score: #{score}"
	end
end
		
	
