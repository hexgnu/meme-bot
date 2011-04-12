require 'isaac/bot'
require 'eventmachine'
require 'yaml'

class MemeBot < Isaac::Bot
  def self.init_config
    directory = "#{ENV['HOME']}/.memebot"

    unless File.directory? directory
      Dir.mkdir directory
    end

    unless File.exist?("#{directory}/config.yml")
      config_file = File.new("#{directory}/config.yml", "w+")
      @config = { :server => 'localhost', :port => '6667', :nick => 'MemeBot', :channel => '#test' }
      config_file.write(@config.to_yaml)
      config_file.close
    else
      @config = YAML::load File.new("#{directory}/config.yml", "r").read
    end

    unless File.exist?("#{directory}/membot.yml")
      File.new("#{directory}/membot.yml", "w").close                       
    end

    @config
  end

  def self.configuration
    @config ||= self.init_config
  end
end

