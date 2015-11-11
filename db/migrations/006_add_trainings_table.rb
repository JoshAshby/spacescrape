Sequel.migration do
  change do
    create_table :trainings do
      primary_key :id

      foreign_key :topic_id, :topics
      foreign_key :webpage_id, :webpages

      DateTime :created_at
      DateTime :updated_at
    end
  end
end
