Sequel.migration do
  change do
    create_table :blacklists do
      primary_key :id

      text :pattern
      index :pattern

      foreign_key :topic_id, :topics

      text :reason

      DateTime :created_at
      DateTime :updated_at
    end
  end
end
