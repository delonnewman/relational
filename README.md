# NAME

Relational - Relational programming for Ruby

# SYNOPSIS

    class User < ActiveRecord::Base
    end
    
    relational do
      people = from('path/to/people.csv', schema: {created_at: :datetime, name: :string}).where(->(row) { person.created_at > Date.today - 1 })
      users = from(User).select(:id, :name)
      people.join(users).select(:id, :name, :created_at).rename(:id, :user_id).to('path/to/report.csv')
    end

# AUTHOR

Delon Newman <contact@delonnewman.name>

