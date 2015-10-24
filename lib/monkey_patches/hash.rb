class Hash
  def symbolize_keys
    Hash[self.map{ |k, v| [k.to_sym, v] }]
  end

  def deep_symbolize_keys
    self.reduce({}) do |memo, (k, v)|
      if v.kind_of? Hash
        memo.merge({ k.to_sym => v.deep_symbolize_keys })
      else
        memo.merge({ k.to_sym => v })
      end
    end
  end

  def stringify_keys
    Hash[self.map{ |k, v| [k.to_s, v] }]
  end

  def deep_stringify_keys
    self.reduce({}) do |memo, (k, v)|
      if v.kind_of? Hash
        memo.merge({ k.to_s => v.deep_stringify_keys })
      else
        memo.merge({ k.to_s => v })
      end
    end
  end
end
