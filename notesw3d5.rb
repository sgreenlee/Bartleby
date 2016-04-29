# METAPROGRAMMING! 

## SEND

class Animal
  def burp
    puts "burp burp burp"
  end

  def sleep(num_of_zs = 1)
    puts "sleep sleep sleep #{"z" * num_of_zs}"

  end

  def cook
    puts "cook cook cook"
  end

  private
  def my_secret
    puts "soooo many secrets."
  end
end

a = Animal.new
a.burp
a.sleep
a.cook

a.send(:burp)
a.send(:sleep)
a.send(:cook)

[:burp, :sleep, :cook].each do |method_name|
  a.send(method_name)
end

a.send(:sleep, 10)

# a.my_secret # this breaks because method is private

a.send(:my_secret) # this works! #send lets you get around private methods.







## TO_PROC and &:method_name


# puts ["Gigi", "Dan", "Fred", "Tommy", "Leen"].map(&:upcase)
# What's going on with this &:upcase ?

# proc = Proc.new { |name| name.upcase }
# puts ["Gigi", "Dan", "Fred", "Tommy", "Leen"].map(&proc)

# proc = Proc.new { |name| name.send(:upcase) }
# puts ["Gigi", "Dan", "Fred", "Tommy", "Leen"].map(&proc)
#
# proc = Proc.new { |object| object.send(:upcase) }
# puts ["Gigi", "Dan", "Fred", "Tommy", "Leen"].map(&proc)

class Symbol
  # there already is a #to_proc method. We're duplicating it for fun.
  def my_to_proc
     Proc.new { |object| object.send(self) }
  end


  def to_proc
    puts "converting #{self} to a proc!"
    Proc.new { |object| object.send(self) }
  end
end

# proc = :upcase.my_to_proc # calling #my_to_proc "procifies" this.
# puts ["Gigi", "Dan", "Fred", "Tommy", "Leen"].map(&proc) # now the & "blockifies".

puts ["Gigi", "Dan", "Fred", "Tommy", "Leen"].map(&:upcase)

# What does the & do?
# toggles between turning a block into a proc, and a proc into a block.
# "blockifies" or "procifies"
# & is a special Ruby thing.










# DEFINE_METHOD

class Dog

  # def run
  #   puts "run run run"
  # end

  define_method(:run) do
    puts "run run run"
  end

  [:walk, :bark].each do |method_name|
    puts "self is now #{self} defining method #{method_name}" # self is Dog class
    define_method(method_name) do |num_times = 1| # num_times is the argument to method_name
      puts "self is now #{self}" # self is dog instance
      puts "#{method_name.to_s} " * num_times
    end
  end

end

# define_method itself is a private method
# the instance methods it defines will take on the privacy of where they're defined

luna = Dog.new
luna.run
luna.walk
luna.bark

# we can't do this because define_method is a private method
# Dog.define_method(:sniff) do
#   puts "sniff sniff sniff"
# end
# luna.sniff --> raises error

# but we know a way around private methods now!
Dog.send(:define_method, :sniff) do
  puts "sniff sniff sniff"
end

# define_method is the argument to send
# sniff is the argument to define_method
# the block puts statement is the argument to sniff
luna.sniff

[:wag, :drool].each do |method_name|
  Dog.send(:define_method, method_name) do |num_times = 1|
    puts "#{method_name.to_s} " * num_times
  end
end

luna.wag(30)
luna.drool(0) # she would never.






# CLASS INSTANCE VARIABLES
class Cat < Animal
  # same as saying Cat = Class.new.
  #Cat is an instance of the class Class.

  @best_color = "purple" # class instance variable

  def self.best_color_for_a_cat # class method
    @best_color || "orange"
  end

  def self.all_cats
    @all_cats ||= [] # "lazy initialize" of @all_cats
  end

  def self.last_made_cat
    @last_made_cat
  end

  def self.last_made_cat=(new_cat)
    @last_made_cat = new_cat
  end

  def initialize(best_color)
    @best_color = best_color # regular ole instance variable
    self.class.all_cats << self
    self.class.last_made_cat = self
  end

  def best_color # instance method
    @best_color
  end

end

paprika = Cat.new("grey")
puts paprika.best_color
puts Cat.best_color_for_a_cat







# meta instance variables!
paprika.instance_variable_get(:@best_color)
paprika.instance_variable_set(:@best_color, "anything else")


class Animal
  def self.set_skills(*skills)
    skills.each do |skill|
      define_method(skill) do
        puts "#{skill.to_s} " * 3
      end
    end

  end
end

class Cat
  set_skills :meow, :purr # looks a lot like attr_accessor, no?
  # set_skills([:meow, :purr]) # you're actually calling the method here, not defining it.
end

paprika.meow
paprika.purr













#
