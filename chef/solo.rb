file_cache_path  "/tmp/chef-solo"
cookbook_path    [ "/var/chef-solo/upstream-cookbooks", "/var/chef-solo/site-cookbooks" ]
role_path        "/etc/chef/roles"
log_level        :info
log_location     STDOUT
ssl_verify_mode  :verify_none
