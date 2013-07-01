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
	end
	class Bot
		def self.instance
			@@instance ||= new
		end
		attr_accessor :bot
		def initialize
			@bot = Cinch::Bot.new do
			  configure do |c|
			    c.server   = "irc.wtfux.org"
			    mong       = Util.instance
			    conf       = mong.getCollection("extendobot","config");
			    nick       = conf.find_one({'key' => "nick"})
			    c.nick     = nick['val']
			    chans      = mong.getCollection("chans","channels")
			    cList      = chans.find({'autojoin' => true}).collect { |x| 
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
	end
end

