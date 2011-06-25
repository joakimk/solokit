require 'ostruct'

class Configuration < OpenStruct
  def initialize(*envs)
    shared_config = YAML.load_file("config.yml")
    
    config = shared_config
    envs.each do |env|
      env_config_file = "envs/#{env}/config.yml"

      config = File.exists?(env_config_file) ?
               YAML.load_file(env_config_file).merge(config) :
               config
    end

    super(config)
  end
end

