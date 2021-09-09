require 'cinch'
require 'open-uri'
require 'ansirc'
require 'uri'
require 'net/http'
#require 'pastebinrb'
require "prime"



require_relative '../classes/Util.rb'
class Artism
  include Cinch::Plugin
  include Hooks::ACLHook
  include Util::PluginHelper
  include Util::PasteMaker
  set :prefix, /^:/
  @clist = %w{art.list}
  @@commands["art.list"] = ":art.list [/regex/[i]] - list all the available art to play  (it will be a lot lol); optional regex to filter it down (and you can do /regex/i for case insensitivity dawg)";
  match(/art\.list\s*$/, method: :artlist)
  match(/art\.list (\/(.+)\/(i)?)/, method: :artlist)
  @@commands["art.play"] = ":art.play <name> - play a specific file, :art.list can be used to see what is available"
  @clist.push "art.play"
  match(/art\.play (.+)/, method: :play_art)
  @@commands["art.random"] = "art.random - play a random art file, who cares what it might be?"
  @clist.push "art.random"
  match(/art\.random/ , method: :artspew)

  timer 30.minutes, method: :gather_files 
  #@@commands["art.web"] = "art.web <url> - grab an ANSI file from the internet at <url>, convert it, and play it."
  #@clist.push "art.web"
  #match /art.web  (#{@urirxp})/, method: :arternets
  #

  def initialize(*args)
    super

    @files = []
    @dir = "etc/art/"
    @urirxp = URI.regexp %w(http https)
    gather_files()
  end

  def gather_files() 
    puts "GATHERING FILES WE ARE GATHERING FILES!"
    @files = Dir.glob("*", base: @dir)
    puts "sexy files #{@files.length}"
  end
  def play_art(m, art)
    response = ""
    path = "#{@dir}#{art}"
    exc = Util::Util.instance.getExcuse()
    if !File.exists? path
      response << "#{m.user.nick}: #{exc} (#{art} does not appear to EXIST smfh lern2type)"
    else 
      begin
        response << "%s %s\n" % [Format(:red, "Now playing: "), Format(:red, :bold, path)]
        response << File.open(path) { |file|
          file.read
        }
      rescue => e
        response = "#{m.user.nick}: #{exc}\n(THERE WAS A FUCKIN ERROR OR SOME SHIT IDK: #{e})" 
      end
    end
    m.reply response
  end

  def artlist(m, *args)
    regex, target, cs = args
    response = "#{m.user.nick}: "
    list = []
    link = ""
    if(regex.nil?) #no regex provided loil
      list = @files #just get em ALL TOGETHER
    else  #oh we have a regex i see
      sluice = cs.nil? ? /#{target}/ : /#{target}/i
      puts "THE FUCKIUNG SLUICE IS #{sluice}"
      list = @files.select { |file| puts file; file.encode('UTF-8').match(sluice) }
    end
    if(list.length > 20) #TOO MANY FSCKING FILES BRO 
      puts "building pastebin thingy..." 
      title = "ANSI Art List"
      title << " (#{regex})" if !regex.nil?

      factors = Prime.prime_division(list.length)
      count, power = factors.detect { |f| f[1] == 1 && f[0] > 2 }
      puts power
      count = 5 if count > 7
      chunks = list.each_slice(count).to_a
      puts "chunks: #{chunks}"
      code = chunks.map { |chunk|
        chunk.join(" ")
      }.join("\n")

      puts "gonna paste this list; info first"
      puts "title: #{title}"
      puts "list length: #{list.length}"
      puts "factors: #{factors.inspect}"
      puts "ultimate count: #{count}"
      puts "chunks: #{chunks.inspect}"
      puts" && code to paste: #{code}"
      begin  
        link = paste(code, title)
        if link.nil?
          throw new Exception("SHIT DIDN'T WORK SOZ")
        else 
          response << "#{list.length} results were found; please visit "
          response << link  << " to see the full list" #build output, use link, ACAB
        end
      rescue Exception => ex
        response <<  Util::Util.instance.getExcuse()
        response << " (SOMETHING FUCKED UP, DEAL WITH IT SORRY)" # told u ACAB, js
      end
    else 
      response << "here are the #{list.length} result(s) found.\n" <<  list.join(", ")
    end
    m.reply response # tell dat nurga what u got my dude
  end
  def artspew(m)
    play_art(m,@files.sample)
  end

  def arternets(m, url)
    #response = ""
  end
end
