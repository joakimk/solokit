include_recipe "ruby-shadow"

if node[:users]

  # We still run ruby 1.8 for some chef things and hash key order
  # is not deterministic. Because of this we sort the keys so that
  # users are created in the same order every time.
  node[:users].keys.sort.each do |username|
    config = node[:users][username]

    group username do
    end
    user username do
      comment config[:comment]
      gid username

      # Added config for home in this site specific cookbook:
      if config[:home]
        if config[:home] != '/root'
          parent_dir = config[:home].split("/")[0..-2].join("/")
          FileUtils.mkdir_p(parent_dir) unless File.exists?(parent_dir)
        end

        home_path = config[:home]
        home home_path
      else
        home_path = "/home/#{username}"
        home home_path
      end

      Kernel.system "chmod 700 #{home_path}" if config[:hidden_home]

      shell "/bin/bash"
      password config[:password]
      supports :manage_home => true
      action [:create, :manage]
    end

    add_keys username
  end
end
