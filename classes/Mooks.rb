#!/usr/bin/env ruby

require 'pathname'
#require 'cinch'
require "json"
#require 'pastebinrb'
#require_relative "Hooks.rb" 
#require_relative "Meta.rb" 

module Mooks
  # # # # # #~ ~# #
  # OPTICON BRUH ##
  # # # # # ~# # #
  class Opticon
    #include Cinch::Plugin
    attr_accessor :match, :callback
    def valid?
      self.match.is_a? Regexp and self.callback.respond_to? :call
    end
    def callback!(&callback) 
      if !callback.respond_to? :call 
        raise "callback not callable?!?"
      end
      self.callback = callback
    end
    def test(str)
      puts "testing #{str} against #{self.match.inspect}"
      return str.match(self.match)
    end
    def stdout
      return self.callback.call
    end

    def match!(match)
      if !match.is_a? Regexp
        if match.is_a? String
          match.
            gsub( /^\/(.+)\/i$/ ,"(?i)\1" ).
            gsub!( /^\/(.+)\/$/, "\1" )
          puts "fine i guess i'll make #{match} a regex whatever hope it works for u"
          match=/#{match}/                  
        else
          raise "#{match.inspect}: NOT A REGEX BRUH"
        end
      end 
      self.match = match
    end

    def initialize
      [].zip( 
             ["valid?", "callback!", "match!"], [
               [  # forks up forks down man forks sideways
                  "validate", "vld8",  "validated", 
                  "not_invalid", "clean", "untainted", "wilco",
                  "green", "good", "coherent", "proper",
                  "vld", "vld", "vld8", "validate" ],
                  [ # a list of aliases for, uh, "callback!"
                    "cb", "clalback", "callbacc", "proc", 
                    "doit", "verb",  "action",
                    "action!", 
                    "Action",  "resolution",
                    "dongexpand", "htp", "state_machine",
                    "keming_machine", "combinator", "ast",
                    "nevergonnagiveyouup", "nevergonnaletyoudown",
                    "never", "gonna", "run", "around", "and", "desert", "you"
                  ],
                  [ # a list of aliases for "match!"
                    "regex", "re", "rxp", "regexp",      #regexp oriented ones
                    "query", "search", "needle",         #maybe more traditional ones
                    "idk", "idfk", "thingy", "guide", "Match",     #...
                    "fuckhole", "jones", "fuckholejones" # re %
                  ]]).each { |pair| 
                    puts "pair: #{pair}"
                    target, patsy = pair
                    puts "target: #{target}, patsy: #{patsy}"
                    alias_method patsy.to_sym, target.to_sym 
                  } 
    end
  end
  # # # # # # # # # # # #
  # no moar opticon lolol##
  #  # # # # # # #3## # # #
end
