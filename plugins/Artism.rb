require 'cinch'
require 'open-uri'
require 'ansirc'
require 'uri'
require 'pastebin'
require "prime"



require_relative '../classes/Util.rb'
class Artism
    include Cinch::Plugin
    include Hooks::ACLHook
    include Util::PluginHelper
    include Util::PasteMaker
    set :prefix, /^:/
    @files = []
    @dir = "etc/art/"
    @urirxp = URI.regexp %w(http https)
    @clist = %w{art.list}
    @@commands["art.list"] = ":art.list [/regex/[i]] - list all the available art to play  (it will be a lot lol); optional regex to filter it down (and you can do /regex/i for case insensitivity dawg)";
    match(/art.list (\/(.+)\/(i)?)?/, method: :list_art)
    @@commands["art.play"] = ":art.play <name> - play a specific file, :art.list can be used to see what is available"
    @clist.push "art.play"
    match(/art.play (.+)/, method: :play_art)
    @@commands["art.random"] = "art.random - play a random art file, who cares what it might be?"
    @clist.push "art.random"
    match(/art.random/ , method: :artspew)

    timer 30.minutes, method: :gather_files 
    timer 2.seconds, method: :gather_files, shots: 1
    #@@commands["art.web"] = "art.web <url> - grab an ANSI file from the internet at <url>, convert it, and play it."
    #@clist.push "art.web"
    #match /art.web  (#{@urirxp})/, method: :arternets

    def gather_files() 
        @files = Dir.glob("*", base: @dir)
        puts "sexy files #{@files.length}"
    end
    def play_art(m, art)
        response = ""
        path = "#{@dir}{art}"
        if !File.exists? path
            exc = Util::Util.instance.getExcuse()
            response << "#{m.user.nick}: #{exc} (#{art} does not appear to EXIST smfh lern2type)"
        else 
            response << "%s %s" % [Format(:red, "Now playing: "), Format(:red, :bold, path)]
            response << File.open("etc/art/#{art}") { |file|
                file.readlines
            }
        end
        m.reply response
    end

    def list_art(m, regex, target, cs)
        response = "#{m.user.nick}: "
        list = []
        if(regex.nil?) #no regex provided loil
            list = @files #just get em ALL TOGETHER
        else  #oh we have a regex i see
            sluice = cs.nil? ? /#{target}/ : /#{target}/i
            list = @files.filter { |file| file.match(sluice) }
        end
        if(list.length > 20) 
            title = "ANSI Art Listing (for #{m.user.nick})"
            title << " (q: #{regex})" if !regex.nil?
            title << " @ " << Time.now.strftime("%s")
            factors = Prime.prime_division(list.length)
            count = factors.detect { |f| f[1] == 1 && f[0] > 2 }
            count = 5 if count > 7
            chunks = list.each_slice(count).to_a
            code = list.reduce("") { |memo, line|
                memo << line.join(" ") << "\n"
            }
            puts "gonna paste this list; info first"
            puts "title: #{title}"
            puts "list length: #{list.length}"
            puts "factors: #{factors.inspect}"
            puts "ultimate count: #{count}"
            puts "chunks: #{chunks.inspect}"
            puts" && code to paste: #{code}"
            response << "#{list.length} results were found; please visit:"
            response << "\n" << paste({
                title: title,
                post: code
            }) << " to see the full list"
            gonna have to experiment first lol
        else 
            puts "less than 20 results found yo: #{list.length}"
            response << "here are the #{list.length} result(s) found.\n" <<  list.join(", ")
        end
        puts "ultimate response: #{response}"
        #m.reply response
    end
    def art_spew(m, cmd)
        play_art(m,@files.sample)
    end

    def arternets(m, url)
        #response = ""
    end
end
