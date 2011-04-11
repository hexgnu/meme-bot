$:.push File.expand_path("../../lib", __FILE__)
require 'ruby-debug'
require 'meme-bot'
require 'meme'
require 'yaml'

@memebot = MemeBot.new do

  on :connect do
    join MemeBot.configuration[:channel]
    msg "#{MemeBot.configuration[:channel]}", "MemeBot -- RailsCamp 2011 Wisla"
  end

  on :private, /killer mem/ do
    msg nick, "_____"
    msg nick, "     |"
    msg nick, "      _____"
    msg nick, "           |"
    msg nick, "            _kill -9 mlomnicki_"
    msg nick, "                               |"
  end

  on :private, /^help/ do
    msg nick, "MemBot usage:"
    msg nick, "list -- list of meme's templates"
    msg nick, "mem '[template_name]' '[first_line]' '[sec_line]' -- get link to meme"
    msg nick, "      for example: mem 'INCEPTION' 'go' 'deeperdeeper' 'lololo'"
    msg nick, "mem! '[template_name]' '[first_line]' '[sec_line]' -- get link to meme and send to channel"
    msg nick, "      for example: mem! 'INCEPTION' 'go' 'deeperdeeper' 'lololo'"
    msg nick, "killer mem -- last generated mem"
  end

  on :private, /\Alist\z/ do
    Meme::GENERATORS.each do |k,v|
      msg nick, "#{k}"
    end
  end

  on :private, /mem( '(.*)'){1,3}/ do
    message = match[1].split("' '")
    msg nick, generate_meme(message)
  end

  on :private, /mem!( '(.*)'){1,3}/ do
    message = match[1].split("' '")
    msg "#{MemeBot.configuration[:channel]}", generate_meme(message)
  end

  on :private, /\Alast (.*)\z/ do
#    number = match[0].to_i
#    database.sort[0...number].reverse.each do |mem|
#      msg nick, "#{mem[0]} - #{mem[1]}"
#    end
     msg nick, "#{match[0]}"
     msg nick, "#{database}"
     msg nick, "LOL"
  end

  helpers do
    def generate_meme(message)
      generator   = message.shift

      meme = Meme.new generator
      link = meme.generate *message

      db = YAML::load File.new("/home/lite/membot.yml", "w").read
      db ||= {}
      db["#{link}"] = Time.now
      file = File.new("/home/lite/membot.yml", "w")
      file.write(db.to_yaml)
      file.close

      link
    end

    def database
      db   = YAML::load File.new("/home/lite/membot.yml", "w+").read
    #  db ||= {}
    end
  end
end

@memebot.configure do |c|
  c.nick    = MemeBot.configuration[:nick]
  c.server  = MemeBot.configuration[:server]
  c.port    = MemeBot.configuration[:port]
  c.verbose = true
end

EM.run do
  @memebot.start
end
