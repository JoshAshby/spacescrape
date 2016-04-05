class Training < Sequel::Model
  many_to_one :webpage
  many_to_one :topic
end
