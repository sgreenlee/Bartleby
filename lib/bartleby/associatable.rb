require 'active_support/inflector'

module Bartleby

  class AssocOptions
    attr_accessor(
      :foreign_key,
      :class_name,
      :primary_key
    )

    def model_class
      class_name.constantize
    end

    def table_name
      class_name.constantize.table_name
    end
  end

  class BelongsToOptions < AssocOptions
    def initialize(name, options = {})
      defaults = {
        foreign_key: "#{name}_id".to_sym,
        primary_key: :id,
        class_name: name.to_s.singularize.capitalize
      }

      self.foreign_key = options[:foreign_key] || defaults[:foreign_key]
      self.primary_key = options[:primary_key] || defaults[:primary_key]
      self.class_name =  options[:class_name]  || defaults[:class_name]
    end
  end

  class HasManyOptions < AssocOptions
    def initialize(name, self_class_name, options = {})
      defaults = {
        foreign_key: "#{self_class_name.underscore}_id".to_sym,
        primary_key: :id,
        class_name: name.to_s.singularize.capitalize
      }

      self.foreign_key = options[:foreign_key] || defaults[:foreign_key]
      self.primary_key = options[:primary_key] || defaults[:primary_key]
      self.class_name =  options[:class_name]  || defaults[:class_name]
    end
  end

  module Associatable
    def belongs_to(name, options = {})
      options = BelongsToOptions.new(name, options)

      assoc_options[name] = options

      define_method(name) do
        foreign_key = send(options.foreign_key)
        target_class = options.model_class
        conditions = {options.primary_key => foreign_key}
        target_class.where(conditions).first
      end
    end

    def has_many(name, options = {})
      options = HasManyOptions.new(name, self.name, options)

      define_method(name) do
        target_class = options.model_class
        primary_key = send(options.primary_key)
        conditions = {options.foreign_key => primary_key}
        target_class.where(conditions)
      end
    end

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
        result = Connection.execute(query_string, self.id)
        result.empty? ? nil : source_options.model_class.new(result.first)
      end
    end

    def assoc_options
      @assoc_options ||= {}
    end
  end
end
