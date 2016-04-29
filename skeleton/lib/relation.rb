class Relation
  include Enumerable

  def initialize(model_class_name)
    @model_class_name = model_class_name
    @cache = nil
    initialize_select_field
  end

  def execute_query
    DBConnection.execute(query, params)
  end

  def model_class
    Object.constant_get(@model_class_name)
  end

  def query_results
    parse(execute_query)
  end

  def query
    <<-SQL
      SELECT
        #{generate_select_field}
      FROM
        #{generate_from_field}
    SQL
      #{generate_joins}
      #{generate_where_field}
      #{generate_group_by_field}
      #{generate_having_field}
  end

  def select(options = {})

  end

  def select_field
    @select_field ||= { model_class.table_name => :* }
  end

  def generate_select_field
    select = []
    select_field.each { |table, column| select.push "#{table}.#{column}"}
    select.join(", ")
  end

  def from_field
    @from_field ||= { model_class.table_name }
  end

  def where_field
    @where_field ||= {}
  end

  def generate_select_field
    where = []
    where_field.each { |table, column| where.push "#{table}.#{column}"}
    select.join(", ")
  end

  def having_field
    @having_field ||= {}
  end

  def params
    @params ||= {}
  end

  def [](index)
    load if @cache.nil?
    @cache[index]
  end

  def each(&prc)
    load if @cache.nil?
    @cache.each(&prc)
  end

  def load(force = false)
    @cache = query_results if force || @cache.nil?
  end

  def parse(results)
    results.map { |result| model_class.new(result) }
  end

end
