require 'cinch'
require 'open-uri'
require_relative '../classes/Util.rb'
class Regices
    include Cinch::Plugin
    include Hooks::ACLHook
    include Util::PluginHelper
    set :prefix, /^s/
    @clist = %w{s/// m//}
    @@commands["s///"] = "s/<search>/<replacement>/[g] - replace <search> with <replacement> from recent messages (g is global)"
    @@commands["m//"] =  "m/<search>/ - search logs for the first message that matches your query"
    match /\/(.+)\/(.+)\/(g)?/, method: :replace;
    match /\/(.+)\//, method: :search, prefix: /^m/

    def replace(m, search, replace, global=nil)
        db = Util::Util.instance.getCollection("extendobot","logs")
        res = db.find({
            "server" => Util::Util.instance.hton("#{m.bot.config.server}:#{m.bot.config.port}"),
            "text"   => /#{search}/,
            "channel" => m.channel.name 
        }).limit(30).sort({"time" => -1})	
        prefixes = [
            ['q', '~'],
            ['a', '&'],
            ['o', '@'],
            ['h', '%'],
            ['+', 'v']
        ]
        out = ""
        debug "rcvd regex: s/#{search}/#{replace}"
        if(res.count > 0) 
            debug "got result: #{res.inspect}"
            row = res.to_a.detect { |x| !x[:text].match /^s\// }
            user = row[:user]
            users = m.channel.users.to_a
            prefix = ""
            modeList = users.detect { |usr| usr[0].nick == user }
            if(!modeList.nil?)
                userModes=modeList.pop
                sel = prefixes.detect { |prefix| userModes.detect { |mode| mode == prefix[0] } }
                prefix = sel.nil? ? "" : sel[1]
                #puts "detected user: #{user}"
                #puts "detected modes: #{userModes.join(', ')}"
                #puts "detected prefix: #{prefix}"
            end
            out << "What #{row[:user]} %s to say was:\n" % [ Format(:italic, :bold, "meant") ]
            out << "<#{prefix}#{row[:user]}>" << " "
            method = :sub
            args = [/#{search}/, replace]
            if(global != nil)
                method = :gsub
            end
            out << row['text'].method(method).call(*args)
        else
            out << "could not find any messages matching /#{search}/"
        end
        m.reply(out)
    end
    def search(m, search)
        db = Util::Util.instance.getCollection("extendobot","logs")
        res = db.find({
            "server" => Util::Util.instance.hton(m.bot),
            "text"   => /#{search}/,
            "channel" => m.channel.name 
        }).sort({"time" => -1})	
        prefixes = [
            ['q', '~'],
            ['a', '&'],
            ['o', '@'],
            ['h', '%'],
            ['+', 'v']
        ]
        out = ""
        debug "rcvd match regex: m/#{search}/"
        if(res.count > 0) 
            debug "got result: #{res.inspect}"
            row = res.to_a.detect { |x| !x[:text].match /^m\// }
            user = row[:user]
            users = m.channel.users.to_a
            modeList = users.detect { |usr| usr[0].nick == user }
            prefix = ""
            if(!modeList.nil?)
                userModes = modeList.pop
                sel = prefixes.detect { |prefix| userModes.detect { |mode| mode == prefix[0] } }
                prefix = sel.nil? ? "" : sel[1]
            end
            #puts "detected user: #{user}"
            #puts "detected modes: #{userModes.join(', ')}"
            #puts "detected prefix: #{prefix}"
            #out << "What #{row[:user]} %s to say was:\n" % [ Format(:italic, :bold, "meant") ]
            out << "<#{prefix}#{row[:user]}>" << " "
            out << row['text']
        else
            out << "can't find no matchin message for s/${search}/ bruh"
        end
        m.reply(out)
    end
end
