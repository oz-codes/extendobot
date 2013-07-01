require 'cinch'
require_relative 'Util.rb'
module Hooks
        module AuthHook
                include Cinch::Plugin
                hook :pre, method: :is_authed
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
		@cmdname = ""
		@levelRequired = ""
		hook :pre, method: :aclcheck
		def aclcheck(m)
			debug "performing aclcheck against #{m.user.name}"
			user = m.user.name
			acl = Util::Util.instance.getDB("acl")
			users = acl.collection("users")
			res = users.find_one({'user' => user})
			Thread.current[:result] = res
			if res['level'] >= @levelRequired 
				Thread.current[:aclpass] = true
				return true
			else
				Thread.current[:aclpass] = false
				return false;
			end
		end
        end
end

