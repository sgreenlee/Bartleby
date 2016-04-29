require "byebug"
require_relative '02_searchable'
require 'active_support/inflector'

# Phase IIIa
class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    Object.const_get(class_name)
  end

  def table_name
    class_name.underscore + 's'
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
  # Phase IIIb
  def belongs_to(name, options = {})
    options = BelongsToOptions.new(name, options)

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

  def assoc_options
    # Wait to implement this in Phase IVa. Modify `belongs_to`, too.
  end
end

class SQLObject
  # Mixin Associatable here...
  extend Associatable
end
