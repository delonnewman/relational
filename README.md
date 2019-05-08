# NAME

Relational - Relational programming for Ruby

# SYNOPSIS

    relational do
      people = from('path/to/people.csv', schema: {created_at: :datetime, name: :string}).select(->(row) { person.created_at > Date.today - 1 })
      users = from('path/to/usernames.json').project(:id, :name)
      people.join(users).project(:id, :name, :created_at).rename(:id, :user_id).to('path/to/report.csv')
    end
    
or

    Relational.from('path/to/people.csv')
              .join(Relational.from('path/to/usernames.json'))
              .project(:id, :name, :created_at)
              .rename(:id, :user_id)
              .to('path/to/data-export.json')

# AUTHOR

Delon Newman <contact@delonnewman.name>

