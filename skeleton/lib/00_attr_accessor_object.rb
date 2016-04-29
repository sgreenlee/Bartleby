class AttrAccessorObject
  def self.my_attr_accessor(*names)

    names.each do |name|
      my_attr_reader(name)
      my_attr_setter(name)
    end
  end

  def self.my_attr_reader(name)
    instance_var_name = "@#{name}".to_sym
    define_method(name) do
      instance_variable_get(instance_var_name)
    end
  end

  def self.my_attr_setter(name)
    instance_var_name = "@#{name}".to_sym
    setter_name = "#{name}=".to_sym
    define_method(setter_name) do |value|
      instance_variable_set(instance_var_name, value)
    end
  end
end
