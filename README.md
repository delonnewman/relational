# NAME

Relational - Relational programming for Ruby

# SYNOPSIS

    > rel1 = Relational::Relation.from(CSV.table('path/to/data.csv')).where(->(row) { row[:created_at] > Date.today - 1 })
    > rel2 = Relational::Relation.from(ActiveRecordInstance)
    > rel1.join(rel2).select(:id, :name, :created_at).rename(:id, :record_id).to('path/to/output.csv')

# AUTHOR

Delon Newman <delnewman@salud.unm.edu>

