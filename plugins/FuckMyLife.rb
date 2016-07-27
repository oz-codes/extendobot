# encoding: utf-8
require 'cinch'
require 'fmylife'
require_relative '../classes/Util.rb'
class FuckMyLife
        include Cinch::Plugin
	include Util::PluginHelper
        set :prefix, /^:/
	#@clist = %w{fml}
        #@@commands["fml"] = ":fml - fuck everyone's life"
        extend Hooks::ACLHook
        #match /fml$/, method: :fml

        def fml (m)
	end
end
