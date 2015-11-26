module Models
  class Keyword < Sequel::Model
    many_to_one :topic
  end
end
