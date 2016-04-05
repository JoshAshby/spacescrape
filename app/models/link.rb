class Link < Sequel::Model
  many_to_one :from, key: :from_id, class: :Webpage
  many_to_one :to,   key: :to_id,   class: :Webpage
end
