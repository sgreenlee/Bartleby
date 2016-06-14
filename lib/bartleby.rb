require "bartleby/configuration"

module Bartleby
  class << self
    attr_accessor :configuration
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure(&prc)
    prc.call(configuration)
  end
end

require "bartleby/objectifier"
