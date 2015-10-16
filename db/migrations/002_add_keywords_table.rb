Sequel.migration do
  change do
    create_table? :keywords do
      primary_key :id

      text :keyword
      index :keyword, unique: true

      integer :weight

      datetime :created_at
      datetime :updated_at
    end
  end
end
