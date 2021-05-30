require 'cinch'
require 'uri'
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
        @@commands["chainsaw"] = ":chainsaw <url> - grabs the text at <url> and chainsaws it to death!!!"
	match /markov$/, method: :markov
	match /markov (\d+)$/, method: :markov
	match /markov (\d+) ([\w ]+)$/, method: :markov
    match /chainsaw (.+)/, method: :chainsaw
	listen_to :channel
	
	def listen(m)
        return if m.message.match /^:/
        text = m.message
        user = m.user.nick
        if(!(["sayok","g1mp","van","durnkb0t", "[0]"].include? user)) 
            process(text,user)
        end
    end

        def process(text,user=nil)
		#puts "Markovian\n\t#{user}: #{text}"
		mkv = Markovin8or.new(2)
		db = Util::Util.instance.getCollection("markov","ngrams") 

		re = /[^a-z0-9' ]/i
        [
          [URI.regexp, ''], 
          [re, ' '],
          [/ {2,}/, ' ']
        ].each { |args| text = text.gsub *args }
		puts "text: #{text}"	
		chains = mkv.chain(text)	
		mkvs = mkv.mongoize	
		mkvs.each { |hash|	
			#next if hash["head"] == nil
			#hash["user"] = user
			#hash["server"] = Util::Util.instance.hton("#{m.bot.config.server}:#{m.bot.config.port}")
			#p hash
			if(db.find({head: hash["head"]}).count > 0)
				#puts "#{hash["head"]} found"
				hash["tails"].each { |tail|
				if(tail != nil)
					db.update_one(
						{head: hash["head"]}, 
						{'$push' => 
							{ tails: tail
							}
						}
					)
				end
				}
			else 
				#puts "#{hash["head"]} not found (#{hash["tails"].inspect})"
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

	def markov(m,length=nil,seed=nil)
                out = start(m,seed,length == nil ? length : length.to_i)
		puts "markov out:\n\t#{out}"
		m.reply(out)
		
	end
        def chainsaw(m, url) 
          #uri = URI.parse url rescue nil
          begin
            uri=URI(url)
          rescue URI::InvalidURIError
            e = Util::Util.instance.getExcuse()
            m.reply("#{m.user.nick}: #{e} [that clearly wasn't a url brah]")
            return 0
          end
          if(uri.nil?)
            e = Util::Util.instance.getExcuse()
            m.reply("#{m.user.nick}: #{e} (that URL you provided was SUS AF bruh)")
            return 0
          end
          content = ""
          open(url) do |f|
            content = f.read
            content.gsub!(%r{</?[^>]+?>}, '')
          end
          e = Util::Util.instance.getSuccess()
          m.reply("#{m.user.nick}:  chainsaw engaged on #{url} ...")
          begin 
            process(content)
          ensure
            m.reply("#{m.user.nick}: #{e} (CHAINSAW SUCCESSFUL!)")
          end

        end
	def getRandomRow(seed = nil)
		db = Util::Util.instance.getCollection("markov","ngrams") 
		ret = []
		if(seed == nil)
			cnt = db.find().count()
			ret = db.find().limit(-1).skip(rand(cnt)).to_a
		else
			ret = getRow(seed)
		end
                puts "ret is: " + ret.inspect
		return ret
	end
		
        def start(m, seed=nil, words=nil)
		db = Util::Util.instance.getCollection("markov","ngrams") 
		res = ""
		if(words == nil)
			words = (4+rand(24).to_i)
		end
		words = words > 32 ? 32 : words
		#puts "begin markov chainsaw"
		#puts "start.count: #{words}, start.seed: #{seed}"
		if seed != nil
                        seed.strip!
                else
                        tmp = getRandomRow().shift
                        puts "tmp = " + tmp.inspect
                        seed = tmp["head"]
                end
		out = ""
		if(seed.match(/ /))
			a = seed.split(/ /)
			seed = a.pop
			out = a.join(" ") << " "
		end
			
		i = 0
		head = ""
		tails = []
		addP = false
		while i < words
			#puts i
		
			loop do
                                row = getRandomRow(seed)
                                if(row.kind_of?(Array)) 
                                  row = row.shift
                                end
				puts "new row #{row.inspect}"
				head = row["head"]
				tails = row["tails"]
				test = row == nil or !row.key?("head") or row["head"] == nil or row["head"] == "" or tails == nil
			#	puts "new row: #{row.inspect}"				
				if test
					addP = true
				else 
					break
				end
			#	puts "heaheahea"
			end
			if addP 
				out += ". "
				addP = false
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
