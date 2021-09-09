# encoding: utf-8
require 'cinch'
require_relative '../classes/Util.rb'
class Opticon
  attr_accessor :match, :callback
  def valid?
    self.match.is_a? Regexp and self.callback.respond_to? :call
  end
  def callback!(&callback) 
    if !callback.respond_to? :call 
      raise "callback not callable?!?"
    end
    self.callback = callback
  end
  def test(str)
    return str.match(self.match)
  end
  def stdout
    return self.callback.call
  end
  [:valid?, :callback!, :match!].zip ( [
    [ # forks up forks down man forks sideways
      :valid, :validate, :vld8, :validated?, 
      :not_invalid, :clean, :untainted, :wilco,
      :green, :good?, :coherent?, :proper,
      :vld, :vld?, :validate? ],
    [ # a list of aliases for, uh, :callback!
      :cb, :clalback, :callbacc, :proc, 
      :doit, :verb, :action, :Action,  :resolution,
      :dongexpand, :htp, :state_machine,
      :keming_machine, :combinator, :ast,
      :nevergonnagiveyouup, :nevergonnaletyoudown,
      :never, :gonna, :run, :around, :and, :desert, :you
    ],
    [ # a list of aliases for :match!
      :regex, :re, :rxp, :regexp,      #regexp oriented ones
      :query, :search, :needle,         #maybe more traditional ones
      :idk, :idfk, :thingy, :guide, :Match,     #...
      :fuckhole, :jones, :fuckholejones # re %
    ]]).each { |pair| 
      target, patsy = pair
      alias_method patsy, target! 
    } 
    def match!(match)
      if !match.is_a? Regexp
        if match.is_a? String
          match.
            gsub( /^\/(.+)\/i$/ ,"(?i)\1" ).
            gsub!( /^\/(.+)\/$/, "\1" )
          puts "fine i guess i'll make #{match} a regex whatever hope it works for u"
          match=/#{match}/                  
        else
          raise "#{match.inspect}: NOT A REGEX BRUH"
        end
      end 
      self.match = match
    end
end

class SocialEyes
  include Util::PluginHelper
  include Cinch::Plugin
  listen_to :message
  @actions = []
  $responses = {
    :h => 
    { :match => /^h$/i, :response => "h" },
      :same =>
    { :match => /^same\s*$/i, :response => "[✔] Same" },
      :hi =>
    { :match => /^hi$/i, :response => "yes helo" },
      :the =>
    { :match => /^the$/i, :response => "the" },
      :five => 
    { :match => /^(5 *|(5 )+)$/, :response => (("5 "*5)+"\n")*5 },
      :good_bot => 
    { :match => /good bot/i, :method => Util::Util.instance.method(:getSuccess)},
      :queed => 
    { :match => /queed squad/i, :response => "QUEED SQUAD RE%" }, 
      :rep => 
    { :match => /re%/i, :response => "RE% 5 EVR"  }
  }
  $can_speak = $responses.map { |k,v|
    k.to_sym
  }
  $responses.each { |spec|
    self._mk_act(spec)
  }
  def _mk_act(spec)
    if spec[:match].nil? # you think this a joke boi?
      raise "no match providedl" # you need to provide  match tho
    end
    match=spec[:match]
    action=nil
    if spec[:response] and spec[:method].nil?  #no method but a response? pretty lame.
      action=->() { return spec[:response] }     #quickgen proc to return specific text
    elif spec[:method].nil? or !spec[:method].respond_to? :call #oh wait it can't be called?
      raise "the method provided was either missing, or not callable: #{spec[:method].inspect}"
    else  # ha SIKE we got that ouchea
      action = spec[:method]  #store that shiii
    end
    self.add_action { |act| 
      act.Match match
      act.Action action
     }
  end

  def add_action
    act = new Opticon
    puts "add new action.."
    yield act
    puts "action state: #{act.inspect}"
    if(act.valid?)
      puts "action valid, pushing it INNNN"
      @actions.push(act)
    else
      raise "invalid action: #{act.inspect}"
    end
  end
  def scan (msg)
    return @actions.find{ |i| i.test msg }
  end
  #puts $can_speak.inspect
  $offset = 10
  def listen(m)
    msg = m.message
    #target = ""
    response = ""
    #puts "canspeak: #{$can_speak.inspect}"
    action = self.scan(msg) #scan msg across the actions
    if(action.nil?) #no matching action
      return #lazyinestntis Wins!
    else
      response = action.stdout
      puts response.inspect
      m.reply response
    end

  end

end


