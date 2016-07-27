require 'cinch'
require 'open-uri'
require_relative '../classes/Util.rb'
require_relative '../classes/Markov.rb'
class Markovian
	include Cinch::Plugin
	include Hooks::ACLHook
	include Util::PluginHelper
	set :prefix, /^:/
	@clist = %w{markov}
	@@commands["markov"] = ":markov <length> <seed>- generates a markov chain of <length> words, starting with optional word <seed>"
	match /markov (\d+)( \w+)?/, method: :markov
	match /markov$/, method: :markov
	listen_to :channel
	
	def listen(m)
		text = m.message
		return if m.message.match /^:/
		user = m.user.nick
		#puts "Markovian\n\t#{user}: #{text}"
		mkv = Markovin8or.new(2)
		db = Util::Util.instance.getCollection("markov","ngrams") 
		re = /[^a-z0-9' ]/i
		text = text.gsub(re, " ").gsub(/ {2,}/, " ")	
		puts "text: #{text}"	
		chains = mkv.chain(text)	
		mkvs = mkv.mongoize	
		mkvs.each { |hash|	
			#next if hash["head"] == nil
			#hash["user"] = user
			#hash["server"] = Util::Util.instance.hton(m.bot.config.server)
			#p hash
			if(db.find({head: hash[:head]}).count > 0)
				#puts "#{hash[:head]} found"
				hash[:tails].each { |tail|
				if(tail != nil)
					db.update_one(
						{head: hash[:head]}, 
						{'$push' => 
							{ tails: tail
							}
						}
					)
				end
				}
			else 
				#puts "#{hash[:head]} not found (#{hash[:tails].inspect})"
				val = db.insert_one(hash)
			end
			#p val
			if(val)
				#puts "success :: #{hash}"
			else
				#puts "failure :: #{hash}"
			end
		}
	end

	def markov(m,length=nil, seed=nil)
		out = start(m,length == nil ? length : length.to_i, seed)
		puts "markov out:\n\t#{out}"
		m.reply(out)
		
	end
	def getRandomRow(seed = nil)
		db = Util::Util.instance.getCollection("markov","ngrams") 
		ret = []
		if(seed == nil)
			cnt = db.find().count()
			ret = db.find().limit(-1).skip(rand(cnt)).to_a.shift
		else
			ret = getRow(seed)
		end
		return ret
	end
		
	def start(m,words=nil, seed=nil)
		db = Util::Util.instance.getCollection("markov","ngrams") 
		res = ""
		if(words == nil)
			words = (4+rand(24).to_i)
		end
		words = words > 32 ? 32 : words
		#puts "begin markov chainsaw"
		#puts "start.count: #{words}, start.seed: #{seed}"
		seed.strip! if seed != nil
		out = ""
		if(seed.match(/ /))
			a = seed.split(/ /)
			seed = a.pop
			out = a.join(" ") << " "
		end
			
		i = 0
		head = ""
		tails = []
		while i < words
			#puts i
		
			loop do
				row = getRandomRow(seed)
				#puts "new row #{row.inspect}"
				head = row[:head]
				tails = row[:tails]
				test = row == nil or !row.key?(:head) or row[:head] == nil or row[:head] == "" or tails == nil
			#	puts "new row: #{row.inspect}"				
				break if !test
			#	puts "heaheahea"
			end
			tail = tails[rand(tails.count())]
			#next if n == nil
			#puts "\t#{head} -> #{n}"
			out += "#{head} "
			seed = tail
			#puts "\trow: "
			#p row
			#puts "out: #{out}"
			i+=1
		end
		#puts "end markov chainsaw"
		out.gsub! /\r?\n/, ""
		return out
	end
	def getRow(head)
		db = Util::Util.instance.getCollection("markov","ngrams") 
		res = db.find({'head' => head}).to_a
		return res[0]
	end
end
