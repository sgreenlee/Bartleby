module Bartleby
  class Configuration
    attr_accessor :seed_file, :db_file, :print_queries

    def print_queries?
      !!@print_queries
    end

    def initialize
      @seed_file = nil
      @db_file = nil
      @print_queries = true
    end
  end
end
