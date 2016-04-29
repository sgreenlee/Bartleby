require_relative 'db_connection'
require 'active_support/inflector'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  def self.columns
    return @columns.dup if @columns
    # ...
    @columns = DBConnection.execute2(<<-SQL).first.map(&:to_sym)
      SELECT
        *
      FROM
        '#{table_name}'
    SQL
    @columns.dup
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
    results = DBConnection.execute(<<-SQL)
      SELECT
        *
      FROM
        '#{table_name}'
    SQL

    parse_all(results)
  end

  def self.parse_all(results)
    results.map { |result| self.new(result) }
  end

  def self.find(id)
    result = DBConnection.execute(<<-SQL, id)
      SELECT
        *
      FROM
        '#{table_name}'
      WHERE
        id = ?
    SQL

    result.empty? ? nil : self.new(result.first)
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
    self.class.columns.map { |col| send(col) }
  end

  def insert
    cols = self.class.columns
    cols.delete(:id)
    col_names = cols.join(", ")
    question_marks = (["?"] * (self.class.columns.count  - 1)).join(", ")
    id_idx = self.class.columns.index(:id)
    values = attribute_values
    values.delete_at(id_idx)

    query_string = <<-SQL
      INSERT INTO
        #{self.class.table_name} (#{col_names})
      VALUES
        (#{question_marks})
    SQL

    DBConnection.execute(query_string, *values)
    self.id = DBConnection.last_insert_row_id
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
