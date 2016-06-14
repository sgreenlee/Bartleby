# Bartleby

Bartleby is a lightweight Object-Relational mapping tool for sqlite3 databases that reproduces some of the core functionality of ActiveRecord.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'bartleby'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install bartleby

## Usage

Bartleby is very easy to set up. First, require the gem:

```ruby
require 'bartleby'
```

Next, configure Bartleby with the path to your sqlite3 database and a file that defines its schema and loads any seed data.

```ruby
Bartleby.configure do |config|
  config.db_file = "PATH/TO/DB/FILE"
  config.seed_file = "PATH/TO/SEED/FILE"
end
```

You're now ready to start creating models with Bartleby! Just subclass Bartleby::Objectifier, making sure to call the ::finalize! method before the end of the model definition.

```ruby
class Cat < Bartleby::Objectifier
  belongs_to :owner
  has_many :feeders

  finalize!
end
```


## API

All subclasses of `Bartleby::Objectifier` expose the following methods, which will be familiar to any user of ActiveRecord:

#### Core ORM Methods

* `::all`
* `::where`
* `::find`
* `::insert`
* `#save`
* `#update`

#### Associations

* `::has_many`
* `::belongs_to`
* `::has_one_through`


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/sgreenlee/bartleby.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
