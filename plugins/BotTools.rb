require 'cinch'
require 'open-uri'
require_relative '../classes/Util.rb'
class BotTools
  include Cinch::Plugin
  include Hooks::ACLHook
  include Util::PluginHelper
  set :prefix, /^:/
  @clist = %w{join part}
  @@commands["join"] = ":join <channel> - join channel"
  @@commands["part"] = ":part <channel> - part channel"
  @@commands["stay"] = ":stay <channel> - join channel, and add it to autojoin for future sessions"
  @@levelRequired = 10
  match(/join (#.+)/ , method: :join)
  match(/part (#.+)/ , method: :part)
  match(/stay (#.+)/ , method: :stay)

  def join(m, chan)
    chan = "##{chan}" if !chan.match(/^#/)
    response = "#{m.user.nick}: " 
    if(!aclcheck(m)) 
      response << Util::Util.instance.getExcuse() << " (you lack sufficient privs bruh)"
    else
      bot = m.bot
      idx = bot.channels.any? { |x| x.name == chan }
      if(!idx) 
        bot.join(chan)
        response << "joined #{chan}"
      else 
        response << "already in #{chan} hurr dee derp"
      end
    end
    m.reply response
  end
  def part(m, chan)
    chan = "##{chan}" if !chan.match(/^#/)
    response = "#{m.user.nick}: " 
    if(!aclcheck(m)) 
      response << Util::Util.instance.getExcuse() << " (where dem privileges @ doe playboi???)"
    else
      bot = m.bot
      idx = bot.channels.any? { |x| x.name == chan }
      if(!idx) 
        response << "parting #{chan}"
        bot.part(chan)
      else 
        response << "not in #{chan} ya styoobid"
      end
    end
    m.reply(response)
  end

  def stay(m, chan)
    debug "request to joinstay chan #{chan}"
    chan = "##{chan}" if !chan.match(/^#/)
    bot = m.bot
    response = "#{m.user.nick}: "
    if(!aclcheck(m))
      response << Util::Util.instance.getExcuse() << " (lol privilege checc, niec try bruh)"
    else 
      if(bot.config.channels.any? { |c| chan == c })
        response << "bruh im already autojoining there anyway. wtf lol"
      else 
        response <<  "adding #{chan} to autojoin...."
        server = Util::Util.instance.hton(bot)
        debug "adding #{chan} to autojoin, server: #{server}"
        Util::Util.instance.addautojoin(server,chan)
        response << "\n and joining #{chan} now..."
        bot.join(chan)
      end
    end
    m.reply response
  end
end



