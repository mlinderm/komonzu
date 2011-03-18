require 'fileutils'

module Komonzu::Command
  class Base
    include Komonzu::Helpers

    attr_accessor :args
    attr_reader :autodetected_name
    def initialize(args, komonzu=nil)
      @args = args
			@komonzu = komonzu
      @autodetected_name = false
    end

    def komonzu
      @komonzu ||= Komonzu::Command.run_internal('auth:client', args)
    end

    def extract_name(force=true)
      name = extract_option('--name', false)
      raise(CommandFailed, "You must specify a project or app name after --name") if name == false
      unless name
        app = extract_name_in_dir(Dir.pwd) ||
        raise(CommandFailed, "No app or project specified.\nRun this command from app folder or set it by adding --name <name>") if force
        @autodetected_name = true
      end
      name
    end

    def extract_name_in_dir(dir)
      return unless remotes = git_remotes(dir)

      if remote = extract_option('--remote')
        remotes[remote]
      elsif remote = extract_name_from_git_config
        remotes[remote]
      else
        apps = remotes.values.uniq
        return apps.first if apps.size == 1
      end
    end

    def extract_name_from_git_config
      remote = %x{ git config komonzu.remote }.strip
      remote == "" ? nil : remote
    end

    def git_remotes(base_dir)
      git_config = "#{base_dir}/.git/config"
      unless File.exists?(git_config)
        parent = base_dir.split('/')[0..-2].join('/')
        return git_remotes(parent) unless parent.empty?
      else
        remotes = {}
        current_remote = nil
        File.read(git_config).split(/\n/).each do |l|
          current_remote = $1 if l.match(/\[remote \"([\w\d-]+)\"\]/)
          app = (l.match(/url = git@#{komonzu.host}:([\w\d-]+)\.git/) || [])[1]
          if current_remote && app
            remotes[current_remote.downcase] = app
            current_remote = nil
          end
        end
        return remotes
      end
    end

    def extract_option(options, default=true)
			values = options.is_a?(Array) ? options : [options]
      return unless opt_index = args.select { |a| values.include? a }.first
      opt_position = args.index(opt_index) + 1
      if args.size > opt_position && opt_value = args[opt_position]
        if opt_value.include?('--')
          opt_value = nil
        else
          args.delete_at(opt_position)
        end
      end
      opt_value ||= default
      args.delete(opt_index)
      block_given? ? yield(opt_value) : opt_value
    end

    def web_url(name)
      "http://#{name}.#{komonzu.host}/"
    end

    def git_url(name)
      "git@mesh.#{komonzu.host}:#{name}.git"
    end

    def app_urls(name)
      "#{web_url(name)} | #{git_url(name)}"
    end

    def escape(value)
      komonzu.escape(value)
    end
  end

  class BaseWithProject < Base
    attr_accessor :project

    def initialize(args, komonzu=nil)
      super(args, komonzu)
      @project ||= extract_name
    end
  end
end

