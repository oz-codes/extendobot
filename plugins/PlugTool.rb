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
		plugs = Hash.new
		Pathname.glob("/var/src/ruby/extendobot/plugins/*.rb").each { |plugin|
				plugname = File.basename(plugin.basename,File.extname(plugin))
                                plugs[plugname] = Hash.new
				plugs[plugname]["enabled"] = m.bot.config.plugins.plugins.include? Object.const_get plugname
				debug plugs[plugname].inspect
                            }
		msg = ''
		plugs.each { |k, v|
			case opt
				when :all
					debug "all plugs pls"
					msg += "#{k} "
				when :disabled
					debug "only disabled pls"
					msg += "#{k} " if !v['enabled']
				when :enabled
					debug "only enabled pls"
					msg += "#{k} " if v['enabled']
				end
		}
		m.reply(msg)
	end
	def pluginfo(m, modname = nil)
		cmds = ""
		if(modname != nil)
			puts modname 
			modname.strip!
			if(File.exist?("/var/src/ruby/extendobot/plugins/#{modname}.rb")) 
				
				ibot = Util::BotFamily.instance.get(Util::Util.instance.hton(m.bot.config.server)).bot
				kc = Kernel.const_get(modname)
				i = ibot.plugins.find_index { |x| x.class == kc }
				if(i == nil) 
					m.reply("#{modname} not loaded currently") 
				else 
					cmds = kc.class_eval { @clist }
					
				end
			end
		else  
			puts "no MODULE"
			cmds = self.class.class_eval { @@commands }
		end
		str = ""
		cmds.each { |k, v|
			str << "#{k} "
		}
		m.reply(str)
	end		
end
		
	
