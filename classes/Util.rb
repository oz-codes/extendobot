require 'pathname'
require 'cinch'
require_relative "Hooks.rb"	

module Util	
	class Util
		require 'mongo';
		include Mongo;
		Mongo::Logger.logger.level = ::Logger::FATAL
		def getExcuse 
			if(@@excuses.count <= 0) 
				rebuildExcuses()
			end
			rdx = rand(@@excuses.count)
			excuse = @@excuses[rdx]
			return excuse
			#todo: get random excuse from extendobot.excuses lmao
		end
		def getSuccess
			if(@@success.count <= 0) 
				rebuildSuccess()
			end
			rdx = rand(@@success.count)
			success = @@success[rdx]
			return success
			#todo: get random success from extendobot.success lmao
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
				@@success.push(excuse[:string])
			}
		end

		def rebuildExcuses
			@@excuses = [];
			excuses = getCollection("extendobot","excuses")
			excuses.find().each { |excuse|
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
		end
		def getDB(dbn)
			if(db = @@mongos[dbn.to_sym])
				puts "#{dbn} exists"
				p db
				return db
			else
				puts "initializing connection to #{dbn}"
				p @@mongos[dbn.to_sym] = Mongo::Client.new([@@url], :database => dbn)
				return @@mongos[dbn.to_sym]
			end
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
			    mong       = Util.instance
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
	module ACLHelper
		def get_acl(m, user)
			users = Util.instance.getCollection("acl","users")
			name = Util.instance.hton(m.bot.config.server)
			res = users.find({'user' => user, 'server' => name}).each.next_values()[0];
		end
	
		def set_acl(m, user, level)
			users = Util.instance.getCollection("acl","users")
			name = Util.instance.hton(m.bot.config.server)
			if(users.find({'user' => user, 'server' => name})) 
				if(users.update({'user' => user, 'server' => name}, {'$set' => {'level' => level}}))
					m.reply("{#user} modified with level #{level}")
				else 
					m.reply("#{user} couldn't be modified")
				end
			else
				m.reply("#{user} not in database")
			end
		end

		def add_acl(m, user, level)
			users = Util.instance.getCollection("acl","users")
			name = Util.instance.hton(m.bot.config.server)
			if(users.find({'user' => user, 'server' => name})) 
				m.reply("#{user} already in database")
			else
				if(users.insert({'user' => user, 'server' => name, 'level' => level}))
					m.reply("#{user} added with level #{level}")
				else
					m.reply("#{user} could not be modified")
				end
			end
		end

		def rm_acl(m, user)
			users = Util.instance.getCollection("acl","users")
			name = Util.instance.hton(m.bot.config.server)
			if(users.find({'user' => user, 'server' => name})) 
				if(users.remove({'user' => user, 'server' => name}))
					m.reply("#{user} removed}")
				else
					m.reply("#{user} could not be removed")
				end
			else
				m.reply("#{user} not in database")			
			end
		end
		

		def list_acl(m)
			users = Util.instance.getCollection("acl","users")
			name = Util.instance.hton(m.bot.config.server)
			users.find({'server' => name}).each { |res|
				m.reply(res['user'] << "@" << res["server"] << ": " << res["level"].to_s)
			}
		end
	end
end

