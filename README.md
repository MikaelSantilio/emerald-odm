# EmeraldODM
EmeraldODM is an Object-Document Mapper (ODM) for Ruby that allows you to interact with MongoDB databases in a simple, Ruby-like way. It provides a high-level, easy-to-use interface for working with MongoDB documents, while abstracting away the low-level details of the MongoDB driver.

The main objective of this gem is primarily to facilitate reading data from a MongoDB database.

# Installation
To install EmeraldODM, simply add it to your Gemfile:
```ruby
gem 'emerald_odm'
```
Then run bundle install to install the gem and its dependencies.

# Usage
Here's a quick example of how to use EmeraldODM to interact with a MongoDB database:

## 1. Setup DB connection
```ruby
require 'emerald_odm'

# Connect to the MongoDB servers before using EmeraldODM
EmeraldODM.databases_settings.merge!(
  {
    blog: [
      [ '192.168.0.1:27017', '192.168.1.1:27017'],
      {
        database: 'blog',
        user: ENV['MONGO_LOGIN'],
        password: ENV['MONGO_PASSWD'],
        auth_source:  ENV['auth_source'],
        max_pool_size: 20,
      }
    ],
    ecommerce: [
      [ '193.168.0.1:27017', '193.168.1.1:27017'],
      {
        database: 'ecommerce',
        user: ENV['MONGO_LOGIN'],
        password: ENV['MONGO_PASSWD'],
        auth_source:  ENV['auth_source'],
        max_pool_size: 20,
      }
    ],
  }
)

```

## 2. Define your model
```ruby
require 'emerald_odm'
# Define a model for the "users" collection
class User < EmeraldODM::Collection
  
  attr_accessor :_id, :name, :email, :posts, :keywords_count

  def self.collection_name
    :users
  end
  
  def self.db_name
    :blog
  end
  
  def self.posts=(posts)
    @posts = posts.map { |post| Post.new(post)}
  end
  
  class Post < EmeraldODM::AttrInitializer
    attr_accessor :id, :title, :body, :created_at, :updated_at
    
    def created_at
      Time.parse(@created_at)
    end

    def updated_at
      Time.parse(@updated_at)
    end
    
    def keywords
      body.scan(/\w+/)
    end
  end
  
end

```

## 3. Use it
```ruby
# Find users using a query
users = User.find(
  {name: 'John Doe'}, # filter query is required
  projection: {name: 1, email: 1, posts: 1, keywords_count: 1}, # optional, the default is to return all fields defined in the model
  limit: 10, # optional, the default is to return all documents
  sort: {name: 1} # optional
)

# users is an array of User objects like Array<User>
users.each do |user|
  posts = user.posts
  all_user_keywords = posts.map(&:keywords).flatten.uniq
  User.update_one(
    {_id: user._id},
    set: {keywords_count: all_user_keywords.count}
  )
end
```

# Advanced usage
EmeraldODM supports advanced usage such as:

## Accessing the underlying MongoDB driver
```ruby
User.collection # returns the underlying MongoDB::Collection object
```

# Contributing
Bug reports and pull requests are welcome on GitHub at https://github.com/MikaelSantilio/emerald-odm/.

# License
The gem is available as open source under the terms of the MIT License.
