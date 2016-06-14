require 'sqlite3'

module Bartleby
  class Connection
    def self.open(db_file_name)
      @db = SQLite3::Database.new(db_file_name)
      @db.results_as_hash = true
      @db.type_translation = true
      @db
    end

    def self.reset
      commands = [
        "rm '#{db_file}'",
        "cat '#{seed_file}' | sqlite3 '#{db_file}'"
      ]
      commands.each { |command| `#{command}` }
      Connection.open(db_file)
    end

    def self.instance
      reset if @db.nil?

      @db
    end

    def self.execute(*args)
      print_query(*args)
      instance.execute(*args)
    end

    def self.execute2(*args)
      print_query(*args)
      instance.execute2(*args)
    end

    def self.last_insert_row_id
      instance.last_insert_row_id
    end

    private

    def self.print_queries?
      Bartleby.configuration.print_queries?
    end

    def self.db_file
      Bartleby.configuration.db_file
    end

    def self.seed_file
      Bartleby.configuration.seed_file
    end

    def self.print_query(query, *interpolation_args)
      return unless print_queries?

      puts '--------------------'
      puts query
      unless interpolation_args.empty?
        puts "interpolate: #{interpolation_args.inspect}"
      end
      puts '--------------------'
    end
  end
end
