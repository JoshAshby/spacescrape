Sequel.migration do
  change do
    create_table? :blacklists do
      primary_key :id

      text :pattern
      index :pattern

      text :reason

      datetime :created_at
      datetime :updated_at
    end
  end
end
