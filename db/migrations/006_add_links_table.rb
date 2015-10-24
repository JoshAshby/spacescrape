Sequel.migration do
  change do
    create_table :links do
      primary_key :id

      foreign_key :webpage_id, :webpages

      text :url

      DateTime :created_at
      DateTime :updated_at
    end
  end
end
