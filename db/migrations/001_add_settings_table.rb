Sequel.migration do
  change do
    create_table? :settings do
      primary_key :id

      varchar :name
      index :name, unique: true

      varchar :value
    end
  end
end
