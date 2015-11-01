class Blacklist < Sequel::Model
  many_to_one :topic
end
