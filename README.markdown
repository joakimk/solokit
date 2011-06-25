A toolkit for provisioning (ubuntu-)servers using chef-solo.

Solokit
---

* A set of wrappers around SSH and Chef Solo. 
* Code for setting up user accounts (optionally setting passwords, ssh-keys and sudo access).
* Uses nesting to override configuration and cookbooks.

Cookbooks and configuration
---

Solokit includes some defaults so that you don't have to repeat the same things for each server. Any "cookbook" or "chef" directories in the root of your project will be copied over the defaults. The same goes for any "cookbook" or "chef" directories for a specific environment.

An environment can be anything from one server to a complete cluster. Within an environment you can run specific configuration for each server, but Solokit defaults to "server.json".

For each layer, Solokit looks for a directory structure like this:

    cookbooks/upstream # Unchanged cookbooks downloaded from opscode or other upstream source.
    cookbooks/site     # Changes or entierly new cookbooks for Solokit, your project or env.
    chef/solo.rb       # Specifies where chef solo should look for files.
    chef/server.json   # Default config, just calls roles/base.rb.
    chef/roles/base.rb # Base configuration

Usage
---

Create the basic directory structure:

    mkdir project
    cd project
    mkdir -p envs/test/chef/roles
    

Add something like this to a Rakefile:

    require 'rubygems'
    require 'solokit'
    
    namespace :test do
      desc "Update system configuration"
      task :provision do
        Solokit::UserJsonGenerator.generate! "test"
        Solokit::Chef.provision!("test", "test.example.com", Solokit::Configuration.new("test"))
      end
    end

Add user configuration to users.yml (optional, but you need to provide a chef/roles/base.json without the users role if you skip this step):

    # User data used to setup user accounts using chef.
    # The hash is generated with "openssl passwd -1".
    
    # Random pwgen password that is used when you don't specify a password for a user.
    default_hash: $1$8jLGWmPB$yFGmUThzbL0DMarc1CIY1/
    
    groups:
      developers: user
    
    users:
      user:
        hash: $1$8jLGWmPB$yFGmUThzbL0DMarc1CIY1/
        keys: user@computer
    
      ## -- Shared users --
      deploy:
        keys: group/developers 
     
    envs:
      test:
        users: group/developers deploy
        sudo: group/developers

And keys below "public_keys" that have names ending in ".pub".

    mkdir -p public_keys
    echo "your key" > public_keys/your_key@computer.pub
    
By default this setup assumes that you can login to root on the server using your ssh key but Solokit also supports running chef as a normal user (with some modifications to solo.rb).

