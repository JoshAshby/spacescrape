Sequel.migration do
  change do
    create_table :settings do
      primary_key :id

      text :name
      index :name, unique: true

      text :value

      DateTime :created_at
      DateTime :updated_at
    end
  end
end
