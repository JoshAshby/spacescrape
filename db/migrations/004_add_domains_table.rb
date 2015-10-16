Sequel.migration do
  change do
    create_table? :domains do
      primary_key :id

      text :domain
      index :domain

      boolean :blacklist
      index :blacklist

      text :reason

      datetime :created_at
      datetime :updated_at
    end
  end
end
