require 'cinch'
require 'open-uri'
require 'ansirc'
require 'uri'
require_relative '../classes/Util.rb'
class Artism
  include Cinch::Plugin
  include Hooks::ACLHook
  include Util::PluginHelper
  set :prefix, /^:/
  @files = []
  @dir = "/home/oz/art/"
  @urirxp = URI.regexp %w(http https)
  @clist = %w{art.list art.play art.randoml}
  @@commands["art.list"] = ":art.list [/regex/] - list all the available art to play  (it will be a lot lol); optional regex to filter it down";
  @@commands["art.play"] = ":art.play <name> - play a specific file, :art.list can be used to see what is available"
  @@commands["art.random"] = "art.random - play a random art file, who cares what it might be?"
  @@commands["art.web"] = "art.web <url> - grab an ANSI file from the internet at <url>, convert it, and play it."
  match /art.play (.+)/, method: :play_art
  match /art.list (/(.+)/)?/, method: :list_art
  match /art.random/, method: :artspew
  match /art.web  (#{@urirxp})/, method: :arternets

  def initialize(*args)
    super
  
    @files = Dir.glob("*", base: @dir)
  def play_art(m, art)
    response = ""

  def list_art(m, regex, target)
    response = ""


  def art_spew(m, cmd)
    response = ""

  def arternets(m, url)
    response = ""
