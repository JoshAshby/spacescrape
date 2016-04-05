Sequel.migration do
  change do
    create_table :links do
      primary_key :id

      foreign_key :from_id, :webpages
      foreign_key :to_id, :webpages

      DateTime :created_at
      DateTime :updated_at
    end
  end
end
