Sequel.migration do
  change do
    create_table? :scrapes do
      primary_key :id

      text :title
      text :url
      text :domain

      text :sha_hash
      text :extension
    end
  end
end
