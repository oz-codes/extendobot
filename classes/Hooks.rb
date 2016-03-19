require 'cinch'
require_relative 'Util.rb'
module Hooks
        module AuthHook
                include Cinch::Plugin
                hook :pre, { method: :is_authed }
                def is_authed(m)
                        user = m.user;
                        if m.authed?
				Thread.current[:authpass] = true
				return true
			else
				Thread.current[:authpass] = false
				return false;
			end
                end
        end
        module ACLHook
                include Cinch::Plugin
		@@levelRequired = 0
		def aclcheck(m)
			user = m.user.name
			users = Util::Util.instance.getCollection("acl","users")
			p users			
			name = Util::Util.instance.hton(m.bot.config.server)
			p name
			rs = users.find({'user' => user, 'server' => name})
			res = rs.to_a[0]
			p res
			Thread.current[:result] = res
			if res[:level].to_i >= @@levelRequired.to_i
				Thread.current[:aclpass] = true
				return true
			else
				Thread.current[:aclpass] = false
				return false;
			end
		end
        end
end

