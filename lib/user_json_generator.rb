require 'yaml'
require 'active_support'
require 'active_support/json/encoding'

module Solokit
  class UserJsonGenerator

    def initialize(key_path, env, opts = {})
      @key_path = key_path

      data = YAML.load_file("users.yml")

      @default_hash = data["default_hash"]
      @users = data["users"]
      @groups = data["groups"]
      @env = data["envs"][env]
      @opts = { :home => "/home" }.merge(opts)
    end

    def generate(target)
      if ENV['DEBUG_USER_JSON']
        require 'pp'
        ::PP.pp generate_json
        exit 0
      end
      File.open(target, 'w') { |f| f.write(generate_json) }
    end

    def self.generate!(env, opts = {})
      UserJsonGenerator.new("public_keys", env, opts).generate("envs/#{env}/chef/roles/users.json")
    end

    private

    def generate_json
      {
        :name => "Users",
        :chef_type => "role",
        :json_class => "Chef::Role",
        :override_attributes => {
        :users => env_users.inject({}) { |h, user|
        h[user] = {
          :password => (@users[user] || {})["hash"] || @default_hash,
          :home => @users[user]["home"] || (user == 'root' ? '/root' : [ @opts[:home], user ].join('/')),
          :hidden_home => !!(@users[user] || {})["hidden_home"]
        }; h
      },
        :ssh_keys => env_users.inject({}) { |h, user|
        h[user] = get_keys(user); h
      },
        :authorization => {
        :sudo => { :users => env_sudo_users }
      }
      },
        :run_list => [ "recipe[users]", "recipe[sudo]" ]
      }.send(ENV['DEBUG_USER_JSON'] ? 'to_hash' : 'to_json')
      #.gsub(/\{/, "{\n").gsub(/\}/, "}\n")
    end

    def env_users
      resolve_users(@env["users"].split)
    end

    def env_sudo_users
      @env["sudo"] && resolve_users(@env["sudo"].split)
    end

    def resolve_users(list)
      list.map { |item|
        if item.include?("group")
          fetch_group_users(item)
        else
          item
        end
      }.flatten
    end

    def get_keys(user)
      (@users[user] || {})["keys"].to_s.split.map do |key_name|
        if key_name.include?("group")
          keys_from_group(key_name)
        else
          key_file = "#{@key_path}/#{key_name}.pub"
          if File.exists?(key_file)
            File.read(key_file).chomp
          else
            raise "Could not find key file: #{key_file}."
          end
        end
      end.join("\n")
    end

    def fetch_group_users(name)
      @groups[name.split('/').last].split
    end

    def keys_from_group(name)
      @groups[name.split("/").last].split.map { |user| get_keys(user) }
    end
  end
end
