# encoding: utf-8
require 'cinch'
require_relative '../classes/Util.rb'
class HHH
  include Util::PluginHelper
  include Cinch::Plugin
  listen_to :message
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
      :bad_bot => 
    { :match => /bad bot/i, :method => Util::Util.instance.method(:getExcuse )},


  }
  $can_speak = $responses.map { |k,v|
    k.to_sym
  }
  #puts $can_speak.inspect
  $offset = 10
  def listen(m)
    msg = m.message
    #target = ""
    response = ""
    #puts "canspeak: #{$can_speak.inspect}"
    $responses.each { |k, v|
      #puts "\ttrying #{msg} against #{v.inspect}"
      if msg.match v[:match]
        #puts "\t#{msg} matched #{v[:match]}"
        #target = k
        #puts "\ttarget: #{target}, response: #{v[:response]}"
        if(v[:method].nil?)
          response = v[:response]
        else 
          response = v[:method].call
        end
      end
    }
    puts response.inspect
=begin
        #haha lol nope no timeouts, we're just gonna reply
        #may the flood be with you
        if(idx = $can_speak.find_index { |x| 
            #puts "\tcomparing #{x} to #{target}"			
            x == target
        }) 
            #puts "deleting #{target}"
            $can_speak.delete(target)
            $can_speak.delete("")
            #puts $can_speak.inspect
        end
        Timer($offset, {:shots => 1}) do 
            unless target == "" or target == nil
                #puts "\tpushing #{target} back into canspeak"
                $can_speak.push target
            end
        end if idx
=end
    m.reply response

  end

end


