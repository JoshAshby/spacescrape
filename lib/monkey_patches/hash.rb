class Hash
  def has_nested_key? *keys
    keys.inject(self) do |memo, key|
      break false unless memo.has_key? key
      break true unless memo[key]

      memo[key]
    end
  end

  def dig *keys
    keys.inject(self) do |memo, key|
      break unless memo[key]

      memo[key]
    end
  end
end
