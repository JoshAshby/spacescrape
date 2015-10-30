Sequel.migration do
  change do
    create_table :keywords do
      primary_key :id

      text :keyword
      index :keyword

      foreign_key :topic_id, :topics

      integer :weight

      DateTime :created_at
      DateTime :updated_at
    end
  end
end
