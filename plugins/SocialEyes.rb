# encoding: utf-8
require 'cinch'
require_relative '../classes/Util.rb'
require_relative '../classes/Mooks.rb'

class SocialEyes
  include Util::PluginHelper
  def initialize(*args)
    super
    puts "WATCH ME INITIALIZE " * 500
    @responses = [
      { :match => /^h$/i, :response => "h" },
      { :match => /^same\s*$/i, :response => "[✔] Same" },
      { :match => /^hi$/i, :response => "yes helo" },
      { :match => /^the$/i, :response => "the" },
      { :match => /^(5 *|(5 )+)$/, :method => :five_alive },
      { :match => /good bot/i, :method => Util::Util.instance.method(:getSuccess)},
      { :match => /bad bot/i, :method => Util::Util.instance.method(:getExcuse)},
      { :match => /queed squad/i, :response => "QUEED SQUAD RE%" }, 
      { :match => /re%/i, :response => "RE% 5 EVR"  }
    ]
    @actions = @responses.map { |i| mak i }
  end
  
  def five_alive
    files = Dir.glob("*", base: "etc/5ive")
    file = files.sample
    res = File.open("etc/5ive/#{file}") { |f|
      f.read
    }
    return res
  end

  def mak(spec)
    puts "mak spec: #{spec.inspect}"
    if spec[:match].nil? # you think this a joke boi?
      raise "no match providedl" # you need to provide  match tho
    end
    match=spec[:match]
    action=nil
    if spec[:method].is_a? Symbol #asshole gave a symbol
      spec[:method] = self.method(spec[:method]) #so let me get the right thing i guess.
    end
    if spec[:response] and spec[:method].nil?  #no method but a response? pretty lame.
      action=->() { return spec[:response] }     #quickgen proc to return specific text
    elsif spec[:method].nil? or !spec[:method].respond_to? :call #oh wait it can't be called?
      raise "the method provided was either missing, or not callable: #{spec[:method].inspect}"
    else  # ha SIKE we got that ouchea
      action = spec[:method]  #store that shiii
    end
    return add_act { |act| 
      act.match! match
      act.callback! &action
    }
  end

  def add_act
    act = Mooks::Opticon.new
    raise "what the fuck are you, stupid?" if !block_given?
    puts "add new action.."
    yield act
    puts "action state: #{act.inspect}"
    if(act.valid?)
      puts "action valid, pushing it INNNN"
      return act
    else
      raise "invalid action: #{act.inspect}"
    end
  end
  def scan (msg)
    if @actions.empty?
      puts "I AM SMOKING ON THAT CRACK MY GUY\n"*100
    end
    puts ("ACTIONS "*20 << "\n") * 50
    puts @actions.inspect
    return @actions.find{ |i| i.test msg }
  end
  include Cinch::Plugin
  listen_to :message
  $responses = 
  #puts $can_speak.inspect
  $offset = 10
  def listen(m)
    msg = m.message
    #target = ""
    response = ""
    #puts "canspeak: #{$can_speak.inspect}"
    puts "scanning #{msg}..."
    action = scan(msg) #scan msg across the actions
    puts "action res: #{action.inspect}"
    if(action.nil?) #no matching action
      puts "fuck lol"
      return #lazyinestntis Wins!
    else
      puts " i got that shit"
      response = action.stdout
      puts response.inspect
      m.reply response
    end

  end

end


