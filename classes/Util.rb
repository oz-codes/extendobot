require 'pathname'
require 'cinch'
require 'pastebinrb'
require_relative "Hooks.rb" 
require_relative "Meta.rb" 

module Util #utilities and such 
  class Util
    require 'mongo';
    include Mongo;
    Mongo::Logger.logger.level = ::Logger::FATAL
    def self.pb()
        @pb ||= Pastebinrb::Pastebin.new 'ce1ac130ad6810a535f893df0647b6c9'
        return @pb
    end
    def getExcuse 
      puts "trying to get an excuse.... excuses count: #{@@excuses.count}"
      if(@@excuses.count <= 0) 
        puts "rebnuilding excuses!!!!"
        rebuildExcuses()
      end
      return @@excuses.sample
    end
    def getSuccess
      puts "trying to get a success.... success count: #{@@success.count}"
      if(@@success.count <= 0) 
        puts "rebuilddng successes!!!"
        rebuildSuccess()
      end
      return @@success.sample
    end
    def addExcuse(exc) 
      excuses = getCollection("extendobot", "excuses")
      res = excuses.insert_one({"string" => exc})
      if(res) 
        rebuildExcuses()
        return 1
      else
        return 0
      end
    end
    def addSuccess(suc) 
      succ = getCollection("extendobot", "success")
      res = succ.insert_one({"string" => suc})
      if(res) 
        rebuildSuccess()
        return 1
      else
        return 0
      end
    end
    def rebuildSuccess
      @@success = []
      success = getCollection("extendobot","success")
      success.find().each { |excuse|
        puts "got a success: " + excuse.inspect
        @@success.push(excuse[:string])
      }
    end

    def rebuildExcuses
      @@excuses = [];
      excuses = getCollection("extendobot","excuses")
      excuses.find().each { |excuse|
        puts "got a excuse: " + excuse.inspect
        @@excuses.push(excuse[:string])
      }
    end

    def self.instance 
      @@instance ||= new
    end

    def initialize  
      @@excuses = [];
      @@success = [];
      @@url = "127.0.0.1:27017"
      @@mongos = {};
      @@mongos[:chans] = Mongo::Client.new([@@url], :database => "chans")
      @@mongos[:extendobot] = Mongo::Client.new([@@url], :database => "extendobot")
      @@mongos[:acl] = Mongo::Client.new([@@url], :database => "acl")
      @@mongos[:markov] = Mongo::Client.new([@@url], :database => "markov")
    end
    def getDB(dbn)
      db = @@mongos[dbn.to_sym]
      if(db)
        #puts "#{dbn} exists"
        p db
        return db
      else
        #puts "initializing connection to #{dbn}"
        p @@mongos[dbn.to_sym] = Mongo::Client.new([@@url], :database => dbn)
        return @@mongos[dbn.to_sym]
      end
    end
    def getCollection(dbn,col) 
      return self.getDB(dbn)[col.to_sym]
    end

    def addautojoin(server,chan)
      server = self.hton(server) if !server.is_a? String
      chans = self.getCollection("chans","channels")
      chans.insert_one({
        'channel' => chan,
        'server'  => server,
        'autojoin' => true,
      })
    end

    def getServers()
      servers = Array.new()
      col = self.getCollection("chans","servers")
      col.find.each { |row| 
        puts "dicks dicks dicks"
        servers.push(row)
      }
      return servers
    end

    def hton(host)
      if(!host.is_a? String) #bot instance was provided, derive host info
        puts "bot instance provided; deriving information automagically"
        host = "#{host.config.server}:#{host.config.port}"
        puts "detected host: #{host}"
      end
      col = getCollection("chans","servers")
      name = ""
      puts "WE TRYNNA FIND HOST: #{host}"
      name = col.find({ "host" => host }).limit(1).to_a[0]
      puts "okay here is the thinng.."
      puts name.inspect
      return name["name"];    
    end
    def MainLoop
      Thread.list.reject { |t| 
        t == Thread.current
      }.each            { |thr|
        thr.join
      }
    end
  end

  class BotFamily
    def self.instance
      @@instance ||= new
    end
    def initialize
      @@family = Hash.new
      @@workers = Hash.new
    end
    def get(name)
      return @@family[name]
    end
    def self.add(opts)
      host = opts['host'] || nil;
      name = opts['name'] || nil;
      @@family[name] = Bot.new(host)
    end
    def add(opts)
      host = opts['host'] || nil;
      name = opts['name'] || nil;
      @@family[name] = Bot.new(host)
    end
    def spawn(opts)
      add(opts)
      start(opts['name'])
    end
    def start(name)
      @@workers[name] ||= Thread.new(@@family[name]) { |bot|
        bot.start
      }
    end
    def startAll() 
      @@family.each { |k, v|
        start(k)
      }
    end
    def stop(name)
      @@workers[name].kill
      @@workers[name] = nil
      @@family[name].stop
    end
    def stopAll()
      @@workers.each { |k, v|
        stop(k)
      }
    end

  end
  class Bot
    attr_accessor :bot
    def initialize(host) 
      @bot = Cinch::Bot.new do
        configure do |c|
          hostname, port = host.split(/:/)
          if(port.nil?)
            port=6667
          else
            port = port.to_i
          end
          c.server   = hostname
          c.port     = port
          if(port == 6697)
            puts "SSL!"
            c.ssl.use  = true
          end
          puts "port: #{port}, ssl.use: #{c.ssl.use}" 
          mong       = Util.instance
          conf       = mong.getCollection("extendobot","config");
          name = mong.hton(host)
          c.server_queue_size = 512
          c.messages_per_second = 64
          c.nick = conf.find({ 'key' => 'nick', 'server' => name }).to_a[0]["val"] 
          c.user = "datbot"
          c.realname = "O Shid It Dat Bot!"
          passwd = nil 
          pass = conf.find({ 'key' => 'pass', 'server' => name })

          if(pass.to_a[0])
            passwd = pass.to_a[0]["val"]
          end
          c.sasl.username=c.nick
          c.sasl.password=passwd

          chans      = mong.getCollection("chans","channels")
          cList      = chans.find({'autojoin' => true, 'server' => name}).collect { |x| 
            x['channel']            
          }
          c.channels = cList
          pList = Array.new
          Pathname.glob("./plugins/*.rb").each { |plugin|
            puts "found plugin #{plugin}"

            load plugin     
            puts Object.const_get(File.basename(plugin.basename,File.extname(plugin)).to_s)
            pList.push(Object.const_get(File.basename(plugin.basename,File.extname(plugin)).to_s))
          }
          c.plugins.plugins = pList
          on :"477" do |m|
            puts "477, trying again in 5..."
            p m               
            Timer(5, {:shots => 4}) { m.bot.join(m.channel) }
          end
          on :connect do |m|
            m.bot.set_mode("+B")

=begin
                if(passwd != nil) 
                        c.plugins.plugins.push(Cinch::Plugins::Identify)
                    c.plugins.options[Cinch::Plugins::Identify] = {
                        :username => c.nick,
                        :type   => :nickserv,
                        :password => passwd
                    }
                 end
=end
          end
        end

      end
    end
    def start
      @bot.start
    end
    def stop
      @bot.stop
    end
  end
  module PasteMaker
    #@@map = {
    #  post: 'code',
    #  title: 'name',
    #  raw: "raw",
    #  expire: "expire_date",
    #  format: "format",
    #}  
    #@@opts = {
    #  "api_paste_expire_date" => "1H",
    #  "api_paste_format" => "text", 
    #  "api_paste_name" => "tcpbot paste",
    #  'api_paste_raw' => "",
    #}

    def paste(post, title=nil, language=nil)
      pb = Util.pb
      title ||= ""
      language ||= "text"
      link = pb.paste_content(
          post,
          title: title,
          format: language
      )
      puts "got pb link: #{link}"
      return link
    end
  end

  module PluginHelper
    @@commands = Hash.new
    @@levelRequired = 0
    def commands
      ret = Array.new 
      @@commands.each { |k, v|
        ret.push k
      }
      return ret
    end

  end
  module ACLHelper
    def get_acl(m, user)
      users = Util.instance.getCollection("acl","users")
      name = Util.instance.hton("#{m.bot.config.server}:#{m.bot.config.port}")
      res = users.find({'user' => user, 'server' => name}).each.next_values()[0];
      return res['level']
    end

    def set_acl(m, user, level)
      users = Util.instance.getCollection("acl","users")
      name = Util.instance.hton("#{m.bot.config.server}:#{m.bot.config.port}")
      response = "#{m.user.nick}: "
      if(users.find({'user' => user, 'server' => name})) 
        if(users.update_one({'user' => user, 'server' => name}, {'$set' => {'level' => level}}))
          response << "{#user} modified with level #{level}"
        else 
          response << "#{user} couldn't be modified"
        end
      else
        response << "#{user} not in database"
      end
      m.reply(response)
    end

    def add_acl(m, user, level)
      users = Util.instance.getCollection("acl","users")
      name = Util.instance.hton("#{m.bot.config.server}:#{m.bot.config.port}")
      response = "#{m.user.nick}: "
      if(users.find({'user' => user, 'server' => name})) 
        response << ("#{user} already in database")
      else
        if(users.insert({'user' => user, 'server' => name, 'level' => level}))
          response << ("#{user} added with level #{level}")
        else
          response << ("#{user} could not be modified")
        end
      end
      m.reply(response)
    end

    def rm_acl(m, user)
      users = Util.instance.getCollection("acl","users")
      name = Util.instance.hton("#{m.bot.config.server}:#{m.bot.config.port}")
      response = "#{m.user.nick}: "
      if(users.find({'user' => user, 'server' => name})) 
        if(users.remove({'user' => user, 'server' => name}))
          response << "#{user} removed}"
        else
          response << "#{user} could not be removed"
        end
      else
        response << "#{user} not in database"          
      end
      m.reply(response)
    end


    def list_acl(m)
      users = Util.instance.getCollection("acl","users")
      name = Util.instance.hton("#{m.bot.config.server}:#{m.bot.config.port}")
      puts "uh we got a lookup for #{name} my ninja"
      users.find({'server' => name}).each { |res|
        m.reply(res['user'] << "@" << res["server"] << ": " << res["level"].to_s)
      }
    end
  end
end
