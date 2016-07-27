require 'cinch'
require_relative '../classes/Util.rb'
class Say
        include Cinch::Plugin
	include Util::PluginHelper
        set :prefix, /^:/
	@clist = %w{say}
        @@commands["say"] = ":say :shyt - say :shyt bro!"
        extend Hooks::ACLHook
        match /say (.+)/;
	match /say (#[\w\d]+) (.+)/, method: :sayto

        def execute(m, phr)
                m.reply "#{phr}"
        end
	
	def sayto(m, chan, phr)
		Channel(chan).send phr
	end
end
