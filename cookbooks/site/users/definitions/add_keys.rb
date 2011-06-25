define :add_keys, :conf => {} do
  config = params[:conf]
  name = params[:name]
  keys = Mash.new
  keys[name] = node[:ssh_keys][name]

  if config[:ssh_key_groups]
    config[:ssh_key_groups].each do |group|
      node[:users].find_all { |u| u.last[:groups].include?(group) }.each do |user|
        keys[user.first] = node[:ssh_keys][user.first]
      end
    end
  end
  
  if config[:extra_ssh_keys]
    config[:extra_ssh_keys].each do |username|
      keys[username] = node[:ssh_keys][username]
    end
  end

  # Made home configurable  
  ssh_dir = "#{node[:users][name][:home] || "/home/#{name}"}/.ssh"

  directory ssh_dir do
    action :create
    owner name
    group config[:groups] ? config[:groups].first.to_s : name
    mode 0755
    not_if { File.exists? ssh_dir }
  end
  
  template "#{ssh_dir}/authorized_keys" do
    source "authorized_keys.erb"
    action :create
    owner name
    group config[:groups] ? config[:groups].first.to_s : name
    variables(:keys => keys)
    mode 0600
    not_if { 
      # To avoid stale handle on NFS mounted homes when writing.
      system "cat #{ssh_dir}/authorized_keys > /dev/null; true"

      defined?(node[:users][name][:preserve_keys]) ? node[:users][name][:preserve_keys] : false }
  end
end
