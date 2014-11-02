== Rail + Grape + Auth

## Database Support
- Postgresql (default)
- Mysql

You can switch database driver at Gemfile.

You can use __structure.sql__ instread of __schema.rb__ by uncomment this code in application.rb
```ruby
# config.active_record.schema_format = :sql
```

## Setup
1. `$ bundle install`
2. create config/database.yml
3. create config/secrets.yml
4. setup database `$ rake db:setup`
