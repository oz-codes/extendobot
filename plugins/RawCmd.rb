require 'cinch'
require 'open-uri'
require_relative '../classes/Util.rb'
class RawCmd
  include Cinch::Plugin
  include Hooks::ACLHook
  include Util::PluginHelper
  set :prefix, /^:/
  @clist = %w{exec raw eval}
  @@commands["exec"] = ":exec <cmd> - run <cmd> through terminal untouched (requires SUPER ADMIN OVER 9000 PRIVILEGES)";
  @@commands["raw"] = ":raw <cmd> - alias for exec. still same privileges lol."
  @@commands["eval"] = ":eval <rcode> - evaluate <rcode> as ruby code (requires SUPER ADMIN OVER 9000 PRIVILEGES)";
  @@levelRequired = 9001
  match /exec (.+)/, method: :raw;
  match /raw (.+)/, method: :raw;
  match /eval (.+)/, method: :reval;


  def raw(m, cmd)
    response = ""
    if(!aclcheck(m)) 
      e = Util::Util.instance.getExcuse()
      response = "#{m.user.nick}: #{e} (yo access level waaay 2 low, playboiiii))"
    else 
      output = IO.popen(cmd, :err => [:child, :out]) do |io|
        io.read
      end
      if($?.success?)
        response = output
      else 
        exc = Util::Util.instance.getExcuse()
        response = "#{m.user.nick}: #{exc} (there was an error running your command...)\n"
        response << "err: #{output}"
      end
    end
    m.reply(response)
  end

  def reval(m, code) 
    response = ""
    if(!aclcheck(m)) 
      e = Util::Util.instance.getExcuse()
      response = "#{e} (YOU LACK THE PROPER ACCESS AND PROLLY R A SKID N E WAZE)"
    else 
      begin
        response = eval(code)
      rescue Exception => exc
        response = exc.to_s.gsub(/for \#.+$/i,"")
      end
    end
    m.reply(response);
  end
end
