Sequel.migration do
  change do
    create_table :webpages do
      primary_key :id

      text :url
      index :url, unique: true

      column :links, "text[]"

      DateTime :last_hit_at

      DateTime :created_at
      DateTime :updated_at
    end
  end
end
