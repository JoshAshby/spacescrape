# Few monkey patches to support symbolizing and stringifying keys within a
# hash. This is useful for example, if you want to use a hash as a splat'd
# input to a function, where the keys of the hash must all be symbols.
#
# @note Most methods here are dumb and don't know how to handle things like
#   calling to_sym on a regex or similar.
#
# Also provides a general #transform_keys() and #transform_values()
#
# Unlike ActiveSupport this doesn't contain any bang operators for these
# methods.
class Hash
  def transform_keys
    return self.enum_for :transform_keys unless block_given?

    self.reduce(self.class.new) do |memo, (k, v)|
      new_key = yield k
      memo.merge({ new_key => v })
    end
  end

  def transform_keys
    return self.enum_for :transform_keys unless block_given?

    self.reduce(self.class.new) do |memo, (k, v)|
      new_val = yield v
      memo.merge({ k => new_val })
    end
  end

  def symbolize_keys
    self.reduce(self.class.new) do |memo, (k, v)|
      memo.merge({ k.to_sym => v })
    end
  end

  def deep_symbolize_keys
    self.reduce(self.class.new) do |memo, (k, v)|
      if v.kind_of? Hash
        memo.merge({ k.to_sym => v.deep_symbolize_keys })
      else
        memo.merge({ k.to_sym => v })
      end
    end
  end

  def stringify_keys
    self.reduce(self.class.new) do |memo, (k, v)|
      memo.merge({ k.to_s => v })
    end
  end

  def deep_stringify_keys
    self.reduce(self.class.new) do |memo, (k, v)|
      if v.kind_of? Hash
        memo.merge({ k.to_s => v.deep_stringify_keys })
      else
        memo.merge({ k.to_s => v })
      end
    end
  end
end
