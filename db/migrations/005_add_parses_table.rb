Sequel.migration do
  change do
    create_table :parses do
      primary_key :id

      foreign_key :webpage_id, :webpages

      DateTime :parsed_at

      DateTime :created_at
      DateTime :updated_at
    end
  end
end
