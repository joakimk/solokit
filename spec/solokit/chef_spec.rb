require "solokit"

# This is just the beginning of a test suite. Solokit was written without tests
# when it was created long ago, but as we still use it I don't feel like adding
# more to it without tests.

describe Solokit::Chef, "#upload" do
  it "note: incomplete test suite"

  it "replaces any previous cookbooks on a server with the current set" do
    # TODO: test the local interactions too
    vm = double
    expect(vm).to receive(:run).with("rm -rf /var/chef-solo /etc/chef").and_return(true)
    expect(vm).to receive(:upload).with("/tmp/solokit_upload/test-name-ip/", "/").and_return(true)
    chef = Solokit::Chef.new(:ip, :name, "test", false, "root", vm)
    chef.upload
  end
end
