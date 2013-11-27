unless attribute?("users")
  node.set["users"] = Mash.new
end

# passwords must be in shadow password format with a salt. To generate: openssl passwd -1
# users[:jose] = {:password => "shadowpass", :comment => "José Amador", :ssh_key => "..." }
