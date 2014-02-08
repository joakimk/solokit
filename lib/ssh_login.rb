require File.expand_path(File.join(File.dirname(__FILE__), 'ssh.rb'))

module Solokit
  class SshLogin
    def initialize(ip, user, debug_ssh)
      @ssh = SSH.new(ip, user, debug_ssh)
    end

    def upload(source, target)
      @ssh.rsync(source, target, true)
    end

    def run(command)
      @ssh.run(command, false)
    end
  end
end
