require 'pathname'
require 'cinch'
require_relative "Hooks.rb"

module Util	
	class Util
		require 'mongo';
		include Mongo;
		def self.instance
			@@instance ||= new
		end
		def initialize	
			@@mongo = MongoClient.new
		end
		def getConn
			return @@mongo
		end
		def getDB(dbn)
			return @@mongo.db(dbn)
		end
		def getCollection(dbn,col) 
			return @@mongo.db(dbn).collection(col)
		end
		def getServers()
			servers = Array.new()
			col = self.getCollection("chans","servers")
			col.find.each { |row| 
				servers.push(row)
			}
			return servers
		end
		def hton(host)
			col = getCollection("chans","servers")
			return col.find_one({ "host" => host })['name']
		end
		def MainLoop
			Thread.list.each { |thr|
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
			    c.server   = host
			    mong       = Util.instance
			    conf       = mong.getCollection("extendobot","config");
			    name = Util.instance.hton(host)
			    nick = conf.find_one({ 'key' => 'nick', 'server' => name })
			    c.nick     = nick['val']
			    chans      = mong.getCollection("chans","channels")
			    cList      = chans.find({'autojoin' => true, 'server' => name}).collect { |x| 
					x['channel']			
			    }
			    c.channels = cList
			    pList = Array.new
			    Pathname.glob("/var/src/ruby/extendobot/plugins/*.rb").each { |plugin|
				require plugin
				pList.push(Object.const_get(File.basename(plugin.basename,File.extname(plugin)).to_s))
			    }
			    c.plugins.plugins = pList;
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
end

