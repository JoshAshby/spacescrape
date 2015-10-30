class Topic < Sequel::Model
  one_to_many :keywords
  one_to_many :settings
  one_to_many :blacklists
end
