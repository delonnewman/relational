Relational
==========

Relational programming for Ruby

Synopsis
========

```ruby
relational do
  people = from('path/to/people.csv', schema: {created_at: :datetime, name: :string}).where(->(row) { person.created_at > Date.today - 1 })
  users = from('path/to/usernames.json').select(:id, :name)
  people.join(users).select(:id, :name, :created_at).rename(:id, :user_id).to('path/to/report.csv')
end
```

or

```ruby
Relational.from('path/to/people.csv')
          .join(Relational.from('path/to/usernames.json'))
          .select(:id, :name, :created_at)
          .rename(:id, :user_id)
          .to('path/to/data-export.json')
```
