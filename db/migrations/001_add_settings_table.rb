Sequel.migration do
  change do
    create_table? :settings do
      primary_key :id

      text :name
      index :name, unique: true

      text :value
    end
  end
end
