extendobot
==========

a magical extensible bot written in ruby


mongo database configuration:

chans.channels
	{channel: 'channelname', server: 'servername', autojoin: true|false}

chans.servers
	{host: 'host.name', name: 'servername', autoconnect: true|false}

extendobot.config
	{key: "key", server: "servername", val: "value"}
	eg: {key: "nick", server: "servername", val: "nick4server"}

acl.users
	{user: "username", server: "servername", level: "access level"}

note that acl is very naive and makes no assumptions about auth status or user host, etc; it just matches on the username

