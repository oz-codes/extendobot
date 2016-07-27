require 'cinch'
require_relative '../classes/Util.rb'
class RainbowPuke
	include Cinch::Plugin
	include Util::PluginHelper
	#@clist = %w{fuck}
	#@@commands["fuck"] = ":fuck <text>: your mom"
	set :prefix, /^:/
	#match /fuck (.*)$/, method: :fuck
	#match /transform :([\w\d]+) (.+)$/, method: :transform,	
	@keycodes = {
		:color    => 3,
		:bold     => 2,
		:italic   => 29,
		:bold	  => 31,
		:reverse  => 22,
		:reset    => 15
	}
	@colors => [	
		:white,
		:black,
		:blue,
		:green,
		:red,
		:brown,
		:purple,
		:orange,
		:yellow,
		:lime,
		:teal,
		:cyan,
		:light-blue,
		:pink,
		:grey,
		:light-grey
	}
	@formats => {
		:fgcolor => [:color, :random_color, ",", :random_color]
	}
	#def process(template,variables)
	#	content = variables[:text]
	#	map = {
	#		:color => @keycodes[:color],
	#		:randomcolor => makeRandom
	#@templates = {
	#	:color => [:color, :randomcolor, :comma, :randomcolor, :text, :
	#def github (m)
	#	m.reply "http://github.com/8dx/extendobot"

	def fuck(m, text)
		#uhh do stuff here
	end
	
	def transform(m, transformation, text)
		#txt = process(transformation.to_sym, text)
		#m.reply(txt)
	end
end
		
	
