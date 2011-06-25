class SSH
  def initialize(ip, user, debug)
    @ip, @user, @debug = ip, user, debug
  end

  def run(command, quiet = true)
    run_command("ssh #{ssh_opts} #{@user}@#{@ip} '#{command}' #{supress_output(quiet)}")
  end

  def rsync(source, target, quiet = false)
    run_command("rsync -e 'ssh #{ssh_opts}' -az #{source} #{@user}@#{@ip}:#{target} #{supress_output(quiet)}")
  end

  private

  def supress_output(hide_stdout)
    if @debug
      ""
    else
      "#{hide_stdout ? '2> /dev/null 1> /dev/null' : '2> /dev/null'}"
    end
  end

  def run_command(cmd)
    puts "SSH | #{cmd}" if @debug
    system(cmd)
  end

  def ssh_opts
    "-o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"
  end
end

