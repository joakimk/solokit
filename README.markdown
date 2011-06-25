A toolkit for provisioning (ubuntu-)servers using chef-solo.

Solokit
---

* A set of wrappers around SSH and Chef Solo. 
* Code for setting up user accounts (optionally setting passwords, ssh-keys and sudo access).
* Uses nesting to override configuration and cookbooks.

Cookbooks and configuration
---

Solokit includes some defaults so that you don't have to repeat the same things for each server. Any "cookbook" or "chef" directories in the root of your project will be copied over the defaults (but not replace them entierly). The same goes for any "cookbook" or "chef" directories for a specific environment.

An environment can be anything from one server to a staging cluster. Within an environment you can run specific configuration for each server, but Solokit defaults to "server.json".

For each layer, Solokit looks for a directory structure like this:

    cookbooks/upstream # Unchanged cookbooks downloaded from opscode, or simular.
    cookbooks/site     # Changes or entierly new cookbooks for Solokit, your project or env.
    chef/solo.rb       # Specifies where to find files.
    chef/server.json   # Default config, just calls roles/base.rb.
    chef/roles/base.rb # Base configuration

Usage
---

TBD

