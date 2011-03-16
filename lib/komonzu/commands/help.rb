module Komonzu::Command
  class Help < Base
    class HelpGroup < Array
      attr_reader :title

      def initialize(title)
        @title = title
      end

      def command(name, description)
        self << [name, description]
      end

      def space
        self << ['', '']
      end
    end

    def self.groups
      @groups ||= []
    end

    def self.group(title, &block)
      groups << begin
        group = HelpGroup.new(title)
        yield group
        group
      end
    end

    def self.create_default_groups!
      return if @defaults_created
      @defaults_created = true
      group 'General Commands' do |group|
        group.command 'help',                         'show this usage'
        group.command 'version',                      'show the gem version'
        group.space
        group.command 'login',                        'log in with your komonzu credentials'
        group.command 'logout',                       'clear local authentication credentials'
        group.space
      end
			group 'Project Commands' do |group|
				group.command 'project:list',                 'list your projects'
        group.command 'project:create [<name>]',      'create a new project'
        group.command 'project:info',                 'show project info'
        group.command 'project:rename <newname>',     'rename the project'
        group.command 'project:destroy',              'destroy the project permanently'
        group.space
			end
		end

    def index
      display usage
    end

    def version
      display Komonzu::Client.version
    end

    def usage
      longest_command_length = self.class.groups.map do |group|
        group.map { |g| g.first.length }
      end.flatten.max

      self.class.groups.inject(StringIO.new) do |output, group|
        output.puts "=== %s" % group.title
        output.puts

        group.each do |command, description|
          if command.empty?
            output.puts
          else
            output.puts "%-*s # %s" % [longest_command_length, command, description]
          end
        end

        output.puts
        output
      end.string
    end
  end
end

Komonzu::Command::Help.create_default_groups!

