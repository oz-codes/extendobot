require 'cinch'
require 'open-uri'
require 'uri'
require_relative '../classes/Util.rb'
class URLThief
  include Cinch::Plugin
  include Hooks::ACLHook
  include Util::PluginHelper
  listen_to :channel
  set :prefix, /^:/
  @clist = %w{url.rand url.find}
  @@commands["url.rand"] = ":url.rand - spit out a random url from the url db"
  match /url\.rand/, method: :url_rand
  @clist.push('url.find')
  @@commands["url.find"] = ":url.find </regex/> - search through url list to find any matching urls?!!?"
  match /url\.find \/(.+?)\//, method: :url_find


  def url_find(m, regex) 
    db = Util::Util.instance.getCollection("extendobot","urls")
    res = db.find({
      "url" => /#{regex}/i
    }).to_a
    resp = "#{m.user.nick}: "
    if(res.empty?)
      resp << Util::Util.instance.getExcuse() << " (couldn't find anything matching /#{regex}/)"
    else 
      resp << "here is what i found for /#{regex}/:\n" << res.map {|e| e['url'] }.join(" | ")
    end
    m.reply(resp)
  end

  def url_rand(m)

    db = Util::Util.instance.getCollection("extendobot","urls")
    proj = {
      "$project": {
        url: 1,
        "_id": 0
      }
    }
    res = db.aggregate([
      { 
        "$match": {
          "server": Util::Util.instance.hton(m.bot),
        }
      },
      proj,
      {
        "$sample": { 
          size: 1
        }
      }
    ]).to_a.shift
    resp = "#{m.user.nick}: "
    if(res.nil?) 
      exc = Util::Util.instance.getExcuse()
      resp << "#{exc} (couldn't find a url lol)"
    else 
      resp << res['url']
      m.reply("#{m.user.nick}: #{res['url']}")
    end
  end

  def listen(m)
    text = m.message
    #user = m.user.nick
    #return if (["sayok","g1mp","van","durnkb0t", "[0]"].include? user)

    return if m.message.match /^:/
    channel = m.channel.name
    schemes = %w{http https ftp gemini gopher irc ssh}
    urxp = URI.regexp(schemes)
    if(text.match(urxp))
      debug "got urlz in msg: #{text}."
      urls = URI.extract(text,schemes)
      debug "url list:" + urls.join(', ')
      urls.each { |url| 
        db = Util::Util.instance.getCollection("extendobot","urls") 
        tm = Time.now.to_i
        server = Util::Util.instance.hton("#{m.bot.config.server}:#{m.bot.config.port}")
        puts "inserting #{url} into db..."
        db.insert_one({'channel' => channel, 'url' => url, 'time' => tm, 'server' => server})
      }
    else 
      puts "oops no urls in '#{text}'"
    end
  end
end
