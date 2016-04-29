require_relative 'db_connection'
require_relative '01_sql_object'

module Searchable
  def where(params)
    param_string = params.keys.map { |name| "#{name} = :#{name}" }.join(" AND ")

    query_string = <<-SQL
      SELECT
        *
      FROM
        #{table_name}
      WHERE
        #{param_string}
    SQL

    # puts query_string
    # puts params
    results = DBConnection.execute(query_string, params)
    parse_all(results)
  end

end

class SQLObject
  extend Searchable
end
