# EmeraldODM

EmeraldODM is an simple ODM (Object-Document Mapper) framework for MongoDB in Ruby.



## Installation

```bash
gem install emerald_odm
```

## Usage

```ruby
require 'emerald_odm'

# 1. Setup DB connection
EmeraldODM.databases_settings.merge!(
  {
    test: [
        [ ENV['IP_MONGO_DATABASE'] ],
        {
          database: 'test',
          user: ENV['DB_LOGIN'],
          password: ENV['DB_PASSWD'],
          auth_source:  ENV['auth_source'],
          max_pool_size: 20,
        }
    ]
  }
)

# 2. Define your model
class Users < EmeraldODM::Collection
  attr_accessor :_id, :name, :email, :age
  
  def self.collection_name
    :users
  end
  
  def self.db_name
    :test
  end
end

# 3. Use it
Users.find(filter: {_id: '5c9b9b9b9b9b9b9b9b9b9b9b'}).first

Users.update_one(filter: {_id: '5c9b9b9b9b9b9b9b9b9b9b9b'}, set: {name: 'John Doe'}, unset: {age: 1})
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/MikaelSantilio/emerald-odm.


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
