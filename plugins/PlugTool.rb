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
        m.reply(plugs.sort.join(" "))
	end
	def pluginfo(m, modname = nil)
        bot = m.bot #how dumb am i lol
		cmds = [] 
        kc = nil
        response = ""
        if(!modname.nil?)
			modname.strip!
			if(File.exist?("plugins/#{modname}.rb")) 
                begin
                    kc = Kernel.const_get(modname)
                rescue Exception => e
                    puts "some sort of really weird shit happened here: #{e}"
                    m.reply "WHAT THE FUCK DID YOU DO: #{e}"
                    return
                end
                puts "goin for thqt I!!!"
				i = bot.plugins.detect { |x| x.class == kc }
				if(i == nil) 
					m.reply("#{modname} not loaded currently: " + Util::Util.instance.getExcuse()) 
				else 
                    puts "evaluating #{i}..."
                    cmds = i.class.class_eval { puts "inside of #{i} trying to get @ @clist which is #{@clist} btw";  @clist }
                    cmds = cmds.map{ |cmd| [cmd, nil] }
				end
			end
		else  
			debug "no MODULE lol"
            cmds = self.class.class_eval { puts "trying to get #{@@commands} for #{self.class}"; @@commands }
        end
        puts "cmds: #{cmds}"
        m.reply sprintf("%s%s", modname.nil? ? "" : "Commands for #{modname}: ", cmds.map(&:shift).sort.join(", "))
        m.reply "(btw, my prefix for commands is %s)" % [Format(:red, :italic, :underline,  ":command")]
	end		
end
		
	
