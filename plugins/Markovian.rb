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
  match /markov (\d+) (.+)/, method: :markov
  match /chainsaw (.+)/, method: :chainsaw
  #timer 10, method: :wharrgarbl, shots: 1
  listen_to :channel
=begin
  def wharrgarbl()
    derp=start(nil,nil,12)
    Channel("#tcpdirect").send(derp)
    offset = (1+rand(14).to_i)*60
    puts "OFFSET: #{offset}"
    offset=30
    Timer(offset) { 
      puts "i wharr then i garbl"
      wharrgarbl()
    }
  end
=end
  def listen(m)
    return if m.message.match /^:/
    text = m.message
    user = m.user.nick
    if(!([
        "professorOak", 
        "sayok",
        "g1mp",
        "van",
        "nav",
        "chan",
        "durnkb0t", 
        "[0]",
        "maple"].
        include? user) or  # ignore the bots lol
        /^(d+ ?)+$/.match(text) #ignore messages that are literally just numbers and nothing else
      )
      process(text,user)
    end
  end

  def process(text,user=nil)
    #puts "Markovian\n\t#{user}: #{text}"
    mkv = Markovin8or.new(2)
    db = Util::Util.instance.getCollection("markov","ngrams") 

    #re = /[^a-z0-9' ]/i 
    re = /[^[:print:]]/ #ignore nonprintable characters
    schemes = %w{http https ftp gemini gopher irc ssh}
    urxp = URI.regexp(schemes)
    [
      [urxp, ''], 
      [re, ''],
      [ /([[:punct]]){3,}/, "\\1"], #replace long runs of punctuation with single 
      [/\d+,\d+./, ''], #strip ##,##C type crap
      #[/[,\.\?!]/, ''],
      [/\b\d{8,}\b/, ''], # strip sequences of just tons of numbers
      [/\s+/, ' '], #reduce multiple spaces to just one
      #[/\b[^\sai5h]\b/i, ''],
    ].each { |args| text = text.gsub *args }
    puts "process text: #{text}"	
    chains = mkv.chain(text)	
    mkvs = mkv.mongoize	
    puts "mkvs: #{mkvs.inspect}"
    mkvs.each { |hash|	
      #next if hash["head"] == nil
      #hash["user"] = user
      #hash["server"] = Util::Util.instance.hton("#{m.bot.config.server}:#{m.bot.config.port}")
      p hash
      db.update_one({
        :head => hash[:head]
      },
      {
        '$push': {
          :tails => {
            '$each': hash[:tails]
          }
        }
      },
      {
        upsert: true
      })
    }
  end

  def markov(m,length=nil,seed=nil)
    out = start(m,seed,length == nil ? length : length.to_i)
    puts "markov out:\n\t#{out}"
    m.reply(out)

  end
  def chainsaw(m, url) 
    #uri = URI.parse url rescue nil
    uri = nil
    begin
      uri=URI.parse(url)
    rescue URI::InvalidURIError
      e = Util::Util.instance.getExcuse()
      m.reply("#{m.user.nick}: #{e} (that URL you provided was SUS AF bruh)")
      return 0
    end
    if(uri.nil? || !(uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)))
      e = Util::Util.instance.getExcuse()
      m.reply("#{m.user.nick}: #{e} [that clearly wasn't a url brah]")
      return 0
    end
    content = ""
    e = Util::Util.instance.getSuccess()
    m.reply("#{m.user.nick}:  chainsaw engaged on #{url} ...")
    uri.open do |f|
      f.each_line { |l|
        line = l.encode('UTF-8','UTF-8', :invalid => :replace).gsub(%r{</?[^>]+?>}, '')
        puts "processing #{line}"
        process(line)
      }
    end
    m.reply("#{m.user.nick}: #{e} (CHAINSAW SUCCESSFUL!)")
  end
  def getRandomRow(seed = nil)
    db = Util::Util.instance.getCollection("markov","ngrams") 
    ret = nil
    while ret.nil?
      if(seed == nil)
        cnt = db.find().count()
        ret = db.find().limit(-1).skip(rand(cnt)).to_a
      else
        ret = getRow(seed)
      end
    end
    return ret
  end

  def start(m=nil, seed=nil, words=nil)
    db = Util::Util.instance.getCollection("markov","ngrams") 
    res = ""
    if(words == nil)
      words = (4+rand(30).to_i)
    end
    words = words > 256 ? 256 : words
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
    tail=""
    sentences = []
    sentence=[]
    row = getRandomRow(seed)
    if(row.kind_of?(Array)) 
      row = row.shift
    end
    if(row.nil? or !row.key?("head") or row["head"].nil? or row["head"] == "" or tails.nil? or tail.nil?)
      e = Util::Util.instance.getExcuse()
      return "#{e} (nurga wtf i just couldn't find anything for #{seed}, me brane too smole)"
    end
    while i < words
      #puts i
      addP = false
      loop do
        row = getRandomRow(seed)
        if(row.kind_of?(Array)) 
          row = row.shift
        end
        #puts "new row #{row.inspect}"
        head = row["head"]
        tails = row["tails"]
        tail = tails[rand(tails.count())]
        #test = row.nil? or !row.key?("head") or row["head"].nil? or row["head"] == "" or tails.nil? or tail.nil?
        test = tail.nil?
        puts "head: #{head}"
        puts "tails: #{tails.inspect}"
        puts "chosen tail: #{tail}"
        puts "test: #{test.inspect}"
        if test and sentence.length > 5
          puts "ADDD THAT PPPP"
          addP = true
        end
        break
        #	puts "heaheahea"
      end
      #puts "\t#{head} -> #{n}"
      sentence.push(head)
      out += "#{head} "
      seed = tail
      #puts "\trow: "
      #p row
      #puts "out: #{out}"
      #if addP # add a period. deal with it. 
      #  sentences.push(sentence)
      #  sentence = []
      #end
      i+=1
    end
    if sentence.count
      sentences.push(sentence)
    end
    return sentences.map { |e| e.join " " }.join(". ")
  end
  def getRow(head)
    db = Util::Util.instance.getCollection("markov","ngrams") 
    res = db.find({'head' => head}).to_a
    return res[0]
  end
end
