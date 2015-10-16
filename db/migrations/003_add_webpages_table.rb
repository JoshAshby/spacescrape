Sequel.migration do
  change do
    create_table? :webpages do
      primary_key :id

      text :title
      text :url

      text :domain
      index :domain

      text :sha_hash
      index :sha_hash

      datetime :created_at
      datetime :updated_at
    end
  end
end
