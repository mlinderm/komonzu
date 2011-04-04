module Komonzu::Command
  class Keys < Base
    def list
      long = args.any? { |a| a == '--long' }
      keys = komonzu.keys
      if keys.empty?
        display "No keys for #{komonzu.user}"
      else
        display "=== #{keys.size} key#{'s' if keys.size > 1} for #{komonzu.user}"
        keys.each do |key|
					display long ? ["'#{key['title']}'", key['key'].strip].join : format_key_for_display(key)
        end
      end
    end
    alias :index :list

    def add
      keyfile = args.first || find_key
      key = File.read(keyfile).strip
			title = key.slice(/ (\S+)$/, 1) || File.basename(keyfile)
      display "Uploading ssh public key #{keyfile} with name '#{title}'"
      komonzu.add_key({:title => title, :key => key})
    end

    def remove
      komonzu.remove_key(args.first)
      display "Key #{args.first} removed."
    end
 
    protected
      def find_key
        %w(rsa dsa).each do |key_type|
          keyfile = "#{home_directory}/.ssh/id_#{key_type}.pub"
          return keyfile if File.exists? keyfile
        end
        raise CommandFailed, "No ssh public key found in #{home_directory}/.ssh/id_[rd]sa.pub.  You may want to specify the full path to the keyfile."
      end

      def format_key_for_display(key)
        type, hex, local = key['key'].strip.split(/\s/)
        ["'#{key['title']}'", type, hex[0,10] + '...' + hex[-10,10], local].join(' ')
      end
  end
end
