module Komonzu::Command::Project
	class Config < Komonzu::Command::BaseWithProject

		def index
			vars = komonzu.config_vars(project)
			display_vars(vars)
		end

		def add
      unless args.size > 0 and args.all? { |a| a.include?('=') }
        raise CommandFailed, "Usage: komonzu project config:add <key>=<value> [<key2>=<value2> ...]"
      end

      vars = args.inject({}) do |vars, arg|
        key, value = arg.split('=', 2)
        vars[key] = value
        vars
      end

      display "Adding config vars:"
      display_vars(vars, :indent => 2)
			komonzu.add_config_vars(project, vars)
      display "done."
    end
		
		def remove
      display "Removing #{args.first} ...", false
      komonzu.remove_config_var(project, args.first)
      display "done."
    end
    alias :rm :remove
		


		protected

		def display_vars(vars, options={})
			max_length = vars.map { |v| v[0].to_s.size }.max
			vars.keys.sort.each do |key|
				if options[:shell]
					display "#{key}=#{vars[key]}"
				else
					spaces = ' ' * (max_length - key.to_s.size)
					display "#{' ' * (options[:indent] || 0)}#{key}#{spaces} => #{format(vars[key], options)}"
				end
			end
		end

		def format(value, options)
			return value if options[:long] || value.to_s.size < 36
			value[0, 16] + '...' + value[-16, 16]
		end
		

	end
end

