require 'pathname'
require 'cinch'
#require "cinch/plugins/identify"
require "mongo"
require "mongo_mapper"
require_relative "Hooks.rb"	

module MongoMapper	
	MongoMapper.connection = Mongo::Connection.new(["127.0.0.1:27017"])
	module Extendobot
		class Config
			include MongoMapper::Document
			
			key :key, String
			key :val, String
			key :server, String
			
			set_database_name "extendobot"
			set_collection_name "config"
		end
		class Log
			include MongoMapper::Document

			key :channel, String
			key :user, String
			key :text, String
			key :time, Int
			key :server, String

			set_database_name "extendobot"
			set_collection_name "logs"
		end
		class Excuse 
			include MongoMapper::Document

			key :string, String
			
			set_database_name "extendobot"
			set_collection_name "excuses"
		end
		class Reminder
			include MongoMapper::Document

			key :user, String
			key :server, String
			key :timestamp, Int
			key :content, String
			

			set_database_name "extendobot"
			set_collection_name "reminders"
		end
		class Success
			include MongoMapper::Document
			
			key :string, String
			
			set_database_name "extendobot"
			set_collection_name "success"
		end
		class Vote 
			include MongoMapper::Document
			
			key :user, String
			key :server, String
			key :voter, String
			key :value, Int
		end
	end
	module Markov
		class Ngram
			include MongoMapper::Document

			set_database_name "markov"
			set_collection_name "ngrams"
		end
	end
	module ACL
		class User
			include MongoMapper::Document
			
			key :user, String
			key :server, String
			key :level, Int
			set_database_name "acl"
			set_collection_name "users"
		end
	end
	module Pastebin
		class Paste
			include MongoMapper::Document

			key :date, Int
			key :size, Int
			key :format_short, String
			key :content, String
			key :size, Int
			key :expire_date, Int
			key :format_long, String
			key :key, String
			key :hits, Int
			key :url, String
			key :title, String
	
			set_database_name "pbscrape"
			set_collection_name "pastes"
		end
	end
	module ServerStuff
		class Channel
			include MongoMapper::Document
			
			key :autojoin, Boolean
			key :server, String
			key :channel, String

			set_database_name 'chans'
			set_collection_name 'channels'
		end
		class Server
			include MongoMapper::Document
			
			key :autoconnect, Boolean
			key :host, String
			key :name. String 

			set_database_name 'chans'
			set_collection_name 'servers'
		end
	end
end
