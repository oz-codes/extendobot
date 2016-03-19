require 'open-uri'
require 'cinch'
require 'nokogiri'
class URLInfo
	include Cinch::Plugin
	listen_to :channel
	
	def listen(m)
		urls = URI.extract(m.message, ["http", "https"])
		urls.map { |url|
			page = Nokogiri::HTML(open(url,{ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE}))
			m.reply("Title: " << page.css("title").text << " (via #{url})")
		}
	end
end
