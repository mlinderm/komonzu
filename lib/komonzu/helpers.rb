module Komonzu
  module Helpers
    def home_directory
      running_on_windows? ? ENV['USERPROFILE'] : ENV['HOME']
    end

    def running_on_windows?
      RUBY_PLATFORM =~ /mswin32|mingw32/
    end

    def running_on_a_mac?
      RUBY_PLATFORM =~ /-darwin\d/
    end

    def display(msg, newline=true)
      if newline
        puts(msg)
      else
        print(msg)
        STDOUT.flush
      end
    end

    def redisplay(line, line_break = false)
      display("\r\e[0K#{line}", line_break)
    end

    def deprecate(version)
      display "!!! DEPRECATION WARNING: This command will be removed in version #{version}"
      display ""
    end

    def error(msg)
      STDERR.puts(msg)
      exit 1
    end

    def confirm(message="Are you sure you wish to continue? (y/n)?")
      display("#{message} ", false)
      ask.downcase == 'y'
    end

    def confirm_command(name = name)
      if extract_option('--force')
        display("Warning: The --force switch is deprecated, and will be removed in a future release. Use --confirm #{name} instead.")
        return true
      end

      raise(Komonzu::Command::CommandFailed, "No project or app specified.\nRun this command from app folder or set it adding --name <app name>") unless name

      confirmed_name = extract_option('--confirm', false)
      if confirmed_name
        unless confirmed_name == name
          raise(Komonzu::Command::CommandFailed, "Confirmed name #{confirmed_name} did not match the selected app or project #{name}.")
        end
        return true
      else
        display ""
        display " !    WARNING: Potentially Destructive Action"
        display " !    This command will affect the project or app: #{name}"
        display " !    To proceed, type \"#{name}\" or re-run this command with --confirm #{name}"
        display ""
        display "> ", false
        if ask.downcase != name
          display " !    Input did not match #{name}. Aborted."
          false
        else
          true
        end
      end
    end

    def format_date(date)
      date = Time.parse(date) if date.is_a?(String)
      date.strftime("%Y-%m-%d %H:%M %Z")
    end

    def ask
      gets.strip
    end

    def shell(cmd)
      FileUtils.cd(Dir.pwd) {|d| return `#{cmd}`}
    end

    def run_command(command, args=[])
      Komonzu::Command.run_internal(command, args)
    end

    def retry_on_exception(*exceptions)
      retry_count = 0
      begin
        yield
      rescue *exceptions => ex
        raise ex if retry_count >= 3
        sleep 3
        retry_count += 1
        retry
      end
    end
  end
end

unless String.method_defined?(:shellescape)
  class String
    def shellescape
      empty? ? "''" : gsub(/([^A-Za-z0-9_\-.,:\/@\n])/n, '\\\\\\1').gsub(/\n/, "'\n'")
    end
  end
end

