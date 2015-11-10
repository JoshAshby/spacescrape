class Topic < Sequel::Model
  one_to_many :keywords
  one_to_many :settings
  one_to_many :blacklists

  def validate
    super

    errors.add :name, 'cannot be empty' if !name || name.empty?
  end

  def before_save
    return false if super == false

    self.key = self.name.downcase.gsub ' ', '_'
  end
end
