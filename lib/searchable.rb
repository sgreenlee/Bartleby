
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

    results = DBConnection.execute(query_string, params)
    parse_all(results)
  end
end
