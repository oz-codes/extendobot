require 'cinch'
require 'open-uri'
require_relative '../classes/Util.rb'
class Replace
	include Cinch::Plugin
	include Hooks::ACLHook
	include Util::PluginHelper
	set :prefix, /^s/
	@clist = %w{s//}
	@@commands["s//"] = "s/<search>/<replacement>/[g] - replace <search> with <replacement> from recent messages (g is global)"
	
	match /\/(.+)\/(.+)\/(g)?/, method: :replace;
	
	def replace(m, search, replace, global=nil)
		db = Util::Util.instance.getCollection("extendobot","logs")
		res = db.find({
			"server" => Util::Util.instance.hton("#{m.bot.config.server}:#{m.bot.config.port}"),
			"text"   => /#{search}/
		}).limit(30).sort({"time" => -1})	
    prefixes = [
      ['q', '~'],
      ['a', '&'],
      ['o', '@'],
      ['h', '%'],
      ['+', 'v']
    ]
		out = ""
		debug "rcvd regex: s/#{search}/#{replace}"
		if(res.count > 0) 
      debug "got result: #{res.inspect}"
      row = res.to_a.detect { |x| !x[:text].match /^s\// }
      user = row[:user]
      users = m.channel.users.to_a
      userModes = users.detect { |usr| usr[0].nick == user }[1]
      sel = prefixes.detect { |prefix| userModes.detect { |mode| mode == prefix[0] } }
      prefix = sel.nil? ? "" : sel[1]
      puts "detected user: #{user}"
      puts "detected modes: #{userModes.join(', ')}"
      puts "detected prefix: #{prefix}"
			out << "<#{prefix}#{row[:user]}>" << ": "
      method = :sub
      args = [/#{search}/, replace]
			if(global != nil)
        method = :gsub
			end
      out << row['text'].method(method).call(*args)
			m.reply(out)
		end
	end
end
