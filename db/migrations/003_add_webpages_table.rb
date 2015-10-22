Sequel.migration do
  change do
    create_table :webpages do
      primary_key :id

      text :url

      text :sha_hash
      index :sha_hash

      text :title

      DateTime :created_at
      DateTime :updated_at
    end
  end
end
