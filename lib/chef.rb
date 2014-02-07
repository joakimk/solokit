require File.expand_path(File.join(File.dirname(__FILE__), 'ssh_login.rb'))

module Solokit
  class Chef
    def initialize(ip, name, env, debug_ssh, user = 'root', vm = nil)
      @ip, @name, @env = ip, name, env

      # TODO: remove the assumption that chef packages are uploaded by ssh
      #       in classes using this class.
      @vm = vm || SshLogin.new(ip, user, debug_ssh)
    end

    def install(use_old_config = false)
      return true if installed?
      puts "#{@name} (#{@env}): Installing chef..."
      dpkg_options = use_old_config ? '--force-confold' : '--force-confnew'
      vm.run(%{export DEBIAN_FRONTEND=noninteractive; apt-get update && apt-get upgrade -y -o Dpkg::Options::="#{dpkg_options}" && apt-get install -o Dpkg::Options::="#{dpkg_options}" ruby ruby1.8-dev libopenssl-ruby wget rsync build-essential -y && wget http://production.cf.rubygems.org/rubygems/rubygems-1.3.7.tgz && tar xfz rubygems-1.3.7.tgz && cd rubygems-1.3.7 && ruby setup.rb && cd .. && rm -rf rubygems-1.3.7* && ln -s /usr/bin/gem1.8 /usr/bin/gem && gem install chef ohai --no-ri --no-rdoc})
    end

    def upload(root = "/")
      solokit_path = File.expand_path(File.join(File.dirname(__FILE__), '..'))

      system("rm -rf #{temp_path}")
      add_upload("#{solokit_path}/cookbooks/upstream/*", "#{root}var/chef-solo/upstream-cookbooks") &&
      add_upload("#{solokit_path}/cookbooks/site/*", "#{root}var/chef-solo/site-cookbooks") &&
      add_upload("cookbooks/upstream/*", "#{root}var/chef-solo/upstream-cookbooks") &&
      add_upload("cookbooks/site/*", "#{root}var/chef-solo/site-cookbooks") &&
      add_upload("envs/#{@env}/cookbooks/*", "#{root}var/chef-solo/site-cookbooks") &&
      add_upload("#{solokit_path}/chef/*", "#{root}etc/chef") &&
      add_upload("chef/*", "#{root}etc/chef") &&
      add_upload("envs/#{@env}/chef/*", "#{root}etc/chef") &&
      vm.run("rm -rf #{root}var/chef-solo #{root}etc/chef") &&
      vm.upload("#{temp_path}#{root}", root) &&
      system("rm -rf #{temp_path}")
    end

    def run(debug = false, root = "/")
      puts "\n#{@name} (#{@env}): Running chef..."
      if debug
        vm.run("#{custom_ruby_path(root)} chef-solo -c #{root}etc/chef/solo.rb -j #{root}etc/chef/#{@name}.json -l debug")
      else
        vm.run("#{custom_ruby_path(root)} chef-solo -c #{root}etc/chef/solo.rb -j #{root}etc/chef/#{@name}.json")
      end
    end

    def self.provision!(env, host, config)
      chef = Chef.new(host, "server", env, config.debug_ssh)
      chef.install || raise("Chef install failed on #{env}")
      chef.upload || raise("Chef upload failed on #{env}")
      chef.run(config.debug_chef) || raise("Chef failed on #{env}")
    end

    private

    attr_reader :vm

    def temp_path
      "/tmp/solokit_upload/#{@env}-#{@name}-#{@ip}"
    end

    def custom_ruby_path(root)
      "PATH=\"#{root}ruby/bin:/sbin:$PATH\""
    end

    def add_upload(from, to)
      if File.exists?(from.gsub(/\*/, ''))
        system("mkdir -p #{temp_path}#{to} && cp -rf #{from} #{temp_path}#{to}")
      else
        true
      end
    end

    def installed?
      @ssh.run('gem list chef | grep chef')
    end
  end
end

