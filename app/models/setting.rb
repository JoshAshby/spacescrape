module Models
  class Setting < Sequel::Model
    many_to_one :topic
  end
end
