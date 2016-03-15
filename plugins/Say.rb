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

        def execute(m, phr)
                m.reply "#{phr}"
        end
end
