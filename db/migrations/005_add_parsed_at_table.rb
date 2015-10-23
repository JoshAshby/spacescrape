Sequel.migration do
  change do
    create_table :parses do
      primary_key :id

      integer :webpage_id

      DateTime :parsed_at

      DateTime :created_at
      DateTime :updated_at
    end
  end
end
