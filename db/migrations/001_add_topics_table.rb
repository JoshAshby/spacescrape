Sequel.migration do
  change do
    create_table :topics do
      primary_key :id

      text :name
      index :name

      text :key
      index :key, unique: true

      DateTime :created_at
      DateTime :updated_at
    end
  end
end
