require File.expand_path(File.join(File.dirname(__FILE__), 'ssh.rb'))

module Solokit
  class Chef
    def initialize(ip, name, env, debug_ssh, user = 'root')
      @ip, @name, @env = ip, name, env
      @ssh = SSH.new(ip, user, debug_ssh)
    end

    def install
      return true if installed?
      puts "#{@name} (#{@env}): Installing chef..."
      @ssh.run('export DEBIAN_FRONTEND=noninteractive; apt-get update && apt-get upgrade -y && apt-get install ruby ruby1.8-dev libopenssl-ruby wget rsync build-essential -y && wget http://production.cf.rubygems.org/rubygems/rubygems-1.3.7.tgz && tar xfz rubygems-1.3.7.tgz && cd rubygems-1.3.7 && ruby setup.rb && cd .. && rm -rf rubygems-1.3.7* && ln -s /usr/bin/gem1.8 /usr/bin/gem && gem install chef ohai --no-ri --no-rdoc')
    end

    def upload(root = "/")
      solokit_path = File.expand_path(File.join(File.dirname(__FILE__), '..'))
      @ssh.run("rm -rf #{root}var/chef-solo", false) &&
      @ssh.run("rm -rf #{root}etc/chef", false) &&
      upload_files("#{solokit_path}/cookbooks/upstream/*", "#{root}var/chef-solo/upstream-cookbooks") &&
      upload_files("#{solokit_path}/cookbooks/site/*", "#{root}var/chef-solo/site-cookbooks") &&
      upload_files("cookbooks/upstream/*", "#{root}var/chef-solo/upstream-cookbooks") &&
      upload_files("cookbooks/site/*", "#{root}var/chef-solo/site-cookbooks") &&
      upload_files("envs/#{@env}/cookbooks/*", "#{root}var/chef-solo/site-cookbooks") &&
      upload_files("#{solokit_path}/chef*", "#{root}etc/chef") &&
      upload_files("chef/*", "#{root}etc/chef") &&
      upload_files("envs/#{@env}/chef/*", "#{root}etc/chef") 
    end

    def run(debug = false, root = "/")
      puts "\n#{@name} (#{@env}): Running chef..."
      if debug
        @ssh.run("#{custom_ruby_path(root)} chef-solo -c #{root}etc/chef/solo.rb -j #{root}etc/chef/#{@name}.json -l debug", false)
      else
        @ssh.run("#{custom_ruby_path(root)} chef-solo -c #{root}etc/chef/solo.rb -j #{root}etc/chef/#{@name}.json", false)
      end
    end

    def self.provision!(env, host, config)
      chef = Chef.new(host, "server", env, config.debug_ssh)
      chef.install || raise("Chef install failed on #{env}")
      chef.upload || raise("Chef upload failed on #{env}")
      chef.run(config.debug_chef) || raise("Chef failed on #{env}")
    end

    private

    def custom_ruby_path(root)
      "PATH=\"#{root}ruby/bin:/sbin:$PATH\""
    end

    def upload_files(from, to)
      return true unless File.exists?(from.gsub(/\*/, ''))
      @ssh.run("mkdir -p #{to}") && @ssh.rsync(from, to, true) 
    end

    def installed?
      @ssh.run('gem list chef | grep chef')
    end
  end
end
