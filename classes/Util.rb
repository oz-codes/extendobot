require 'pathname'
require 'cinch'
require_relative "Hooks.rb"

module Util	
	class Util
		require 'mongo';
		include Mongo;
		Mongo::Logger.logger.level = ::Logger::FATAL
		def self.instance 
			@@instance ||= new
		end
		def initialize	
			@@url = "127.0.0.1:27017"
			@@mongos = {};
			@@mongos[:chans] = Mongo::Client.new([@@url], :database => "chans")
			@@mongos[:extendobot] = Mongo::Client.new([@@url], :database => "extendobot")
			@@mongos[:acl] = Mongo::Client.new([@@url], :database => "acl")
		end
		def getDB(dbn)
			return @@mongos[dbn.to_sym]
		end
		def getCollection(dbn,col) 
			return self.getDB(dbn)[col.to_sym]
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
			name = ""
			name = col.find({ "host" => host }).limit(1).each 
			return name.next_values()[0]["name"];	
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
			    mong       = Util.new
			    conf       = mong.getCollection("extendobot","config");
			    name = mong.hton(host)
			    c.nick = conf.find({ 'key' => 'nick', 'server' => name }).each.next_values()[0]["val"] 
			    chans      = mong.getCollection("chans","channels")
			    cList      = chans.find({'autojoin' => true, 'server' => name}).collect { |x| 
					x['channel']			
			    }
			    c.channels = cList
			    pList = Array.new
			    Pathname.glob("/var/src/ruby/extendobot/plugins/*.rb").each { |plugin|
				puts "found plugin #{plugin}"
					
				load plugin
				puts Object.const_get(File.basename(plugin.basename,File.extname(plugin)).to_s)
				pList.push(Object.const_get(File.basename(plugin.basename,File.extname(plugin)).to_s))
			    }
			    c.plugins.plugins = pList
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

