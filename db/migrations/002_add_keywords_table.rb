Sequel.migration do
  change do
    create_table? :keywords do
      primary_key :id

      varchar :keyword
      index :keyword, unique: true

      integer :weight
    end
  end
end
