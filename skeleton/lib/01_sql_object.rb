require_relative 'db_connection'
require 'active_support/inflector'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  def self.columns
    return @columns if @columns
    # ...
    @columns = DBConnection.execute2(<<-SQL).first.map(&:to_sym)
      SELECT
        *
      FROM
        '#{table_name}'
    SQL
  end

  def self.finalize!
    columns.each do |column|
      # getter
      define_method(column) do
        attributes[column]
      end

      setter_name = "#{column}=".to_sym
      define_method(setter_name) do |value|
        attributes[column] = value
      end
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name || self.name.tableize
  end

  def self.all
    # ...
  end

  def self.parse_all(results)
    # ...
  end

  def self.find(id)
    # ...
  end

  def initialize(params = {})
    params.each do |attr_name, value|
      raise "unknown attribute '#{attr_name}'" unless valid_attribute? attr_name
      send("#{attr_name}=".to_sym, value)
    end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    # ...
  end

  def insert
    # ...
  end

  def update
    # ...
  end

  def save
    # ...
  end

  private

  def valid_attribute?(attr_name)
    self.class.columns.include? attr_name.to_sym
  end
end
