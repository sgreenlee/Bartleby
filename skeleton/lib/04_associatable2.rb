require_relative '03_associatable'

# Phase IV
module Associatable
  # Remember to go back to 04_associatable to write ::assoc_options

  def has_one_through(name, through_name, source_name)


    define_method(name) do
      through_options = self.class.assoc_options[through_name]
      source_options = through_options.model_class.assoc_options[source_name]

      fk1 = through_options.foreign_key
      pk1 = through_options.primary_key

      fk2 = source_options.foreign_key
      pk2 = source_options.primary_key

      t1 = self.class.table_name
      t2 = through_options.table_name
      t3 = source_options.table_name

      first_join_conditions = "#{t1}.#{fk1} = #{t2}.#{pk1}"
      second_join_conditions = "#{t2}.#{fk2} = #{t3}.#{pk2}"
      primary_key = through_options.primary_key

      query_string = <<-SQL
        SELECT
          #{t3}.*
        FROM
          #{t1}
        JOIN
          #{t2}
        ON
          #{first_join_conditions}
        JOIN
          #{t3}
        ON
          #{second_join_conditions}
        WHERE
          #{t1}.#{primary_key} = ?
      SQL
      result = DBConnection.execute(query_string, self.id)
      result.empty? ? nil : source_options.model_class.new(result.first)
    end
  end
end
