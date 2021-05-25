require 'cinch'
require_relative '../classes/Util.rb'
class PlugTool
	include Cinch::Plugin
	include Util::PluginHelper
	@clist = %w{plugs commands}
	@@commands["plugs"] = ":plugs - produce list of plugins available"
	@@commands["commands"] = ":commands <plugin> - produce commands for <plugin>, or list of all commands if no plugin is given"
	set :prefix, /^:/
	match /commands( .+)?/, method: :pluginfo
	match /plugs( .+)?/, method: :interstitial

	def interstitial(m, filter = nil) 
		debug "in interstitial, for filter to #{filter.to_s}"
		if(filter != nil) 
			filter.strip!
		end
		case filter
			when ".enabled"
				plugs(m,:enabled)
			when ".disabled"
				plugs(m,:disabled)
			else
				plugs(m, :all)
		end
	end
	def plugs(m, opt) 
		debug "in plugs, got opt as #{opt.to_s}"
        debug "plugins: #{m.bot.config.plugins.plugins.inspect}"
        #plugs = Hash.new #okay this really is not necessary. we can handle this in the glob.
		plugs = Dir.glob("./plugins/*.rb").map { |plugin| #just map the glob to the necessary list
            plugname = File.basename(plugin,".*")
            puts "PLUGNAME: #{plugname}"
            enabled = m.bot.config.plugins.plugins.include? Object.const_get plugname
            puts "and enabled: #{enabled.inspect}"
            ret = ( opt == :enabled  &&  enabled ) ||
                  ( opt == :disabled && !enabled ) ||
                  ( opt == :all                  ) ?
                  plugname : nil
            puts "\t and ret is #{ret.inspect}"
            ret
        }.reject(&:nil?)
        puts "making the ultimate outcome #{plugs.inspect}"
=begin      
keeping this around for posterity...
and as a reminder of how stupid i can be.

		msg = ''
        plugs.sort.to_h.
          each { |k, v|
			case opt
				when :all
					debug "all plugs pls"
					msg += "#{k} "
				when :disabled
					debug "only disabled pls"
					msg += "#{k} " if !v
				when :enabled
					debug "only enabled pls"
					msg += "#{k} " if v
				end
		}
=end
        m.reply(plugs.sort.join(" "))
	end
	def pluginfo(m, modname = nil)
		cmds = ""
        if(!modname.nil?)
			debug "getting pluginfo for  #{modname}"
			modname.strip!
			if(File.exist?("./plugins/#{modname}.rb")) 
              debug "looky here, plugins/#{modname}.rb does exist!"
				
              #ibot = Util::BotFamily.instance.get(Util::Util.instance.hton(Util::Util.buildHost(m.bot)#{m.bot.config.server}:#{m.bot.config.port}")).bot
              #should be able to just do....
              ibot = m.bot #how dumb am i lol
				kc = Kernel.const_get(modname)
				i = ibot.plugins.find_index { |x| x.class == kc }
				if(i == nil) 
					m.reply("#{modname} not loaded currently: " + Util::Util.instance.getExcuse()) 
				else 
                    debug "grabbing @clist for #{kc}"
					cmds = kc.class_eval { @clist }
					
				end
			end
		else  
			debug "no MODULE lol"
			cmds = self.class.class_eval { @@commands }
        end
        m.reply sprintf("%s%s", modname.nil? ? "" : "Commands for #{modname}: ", cmds.sort.map(&:shift).join(" "))
        m.reply "(btw, my prefix for commands is :)"
	end		
end
		
	
