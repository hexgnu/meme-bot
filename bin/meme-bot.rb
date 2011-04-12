$:.push File.expand_path("../../lib", __FILE__)
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

  on :channel, /\Amem!\z/ do
    msg channel, random_mem
  end

  on :private, /^help/ do
    msg nick, "MemBot usage:"
    msg nick, "list -- list of meme's templates"
    msg nick, "mem '[template_name]' '[first_line]' '[sec_line]' -- get link to meme"
    msg nick, "      for example: mem 'INCEPTION' 'go' 'deeperdeeper' 'lololo'"
    msg nick, "mem! '[template_name]' '[first_line]' '[sec_line]' -- get link to meme and send to channel"
    msg nick, "      for example: mem! 'INCEPTION' 'go' 'deeperdeeper' 'lololo'"
    msg nick, "killer mem -- ;-)"
    msg nick, "last [number] -- last [number] memes"
    msg nick, "mem! -- random mem from memegenerator.net"
  end

  on :private, /\Alist\z/ do
    list = []
    Meme::GENERATORS.each do |k,v|
      list << k
    end
    msg nick, list.join(" ")
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
    number = match[0].to_i
    database.sort_by{|k,v| v}[0...number].reverse.each do |mem|
      msg nick, "#{mem[0]} - #{mem[1]}"
    end
  end

  helpers do
    def generate_meme(message)
      generator   = message.shift

      meme = Meme.new generator
      begin
        link = meme.generate *message

        db = YAML::load File.new("#{home_directory}/membot.yml", "r").read
        db ||= {}
        db["#{link}"] = Time.now if link
        file = File.new("#{home_directory}/membot.yml", "w")
        file.write(db.to_yaml)
        file.close
      rescue
        link = "Something went wrong -- maybe number of arguments"
      end

      link
    end

    def database
      db = YAML::load File.new("#{home_directory}/membot.yml", "r").read
      db ||= {}      
    end

    def home_directory
      "#{ENV['HOME']}/.memebot"
    end

    def random_mem
      begin
        Nokogiri::HTML(Net::HTTP.get(URI.parse "http://memegenerator.net/")).xpath("//img[@class = 'large rotated']").first['src']
      rescue Exception
        return "Problem with connection to memegenerator.net"
      end
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
