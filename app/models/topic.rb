class Topic < Sequel::Model
  one_to_many :keywords
  one_to_many :settings
  one_to_many :blacklists

  def validate
    super

    errors.add :name, 'cannot be empty' if name.blank?
  end

  def key
    @key ||= name.underscore
  end
end
