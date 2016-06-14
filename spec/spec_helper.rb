require 'bundler/setup'
Bundler.setup

require 'bartleby' # and any other gems you need
require 'byebug'

RSpec.configure do |config|
  # some (optional) config here
end

Bartleby.configure do |config|
  config.seed_file = File.join(File.dirname(__FILE__), 'cats.sql')
  config.db_file = File.join(File.dirname(__FILE__), 'cats.db')
  config.print_queries = false
end
