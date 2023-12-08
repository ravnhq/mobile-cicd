# frozen_string_literal: true

# @param [String] value
# @return [TrueClass, FalseClass]
def parse_boolean(value, default)
  value = value.downcase.strip
  blank?(value) ? default : %w[yes true 1].include?(value)
end

# @param [Object] obj
# @return [TrueClass, FalseClass]
def blank?(obj)
  return obj.strip.empty? if obj.is_a?(String)

  obj.respond_to?(:empty?) ? obj.empty? : !obj
end

# @param [Object] obj
# @param [Object] fallback
# @return [Object] Either obj or fallback
def fallback(obj, fallback)
  blank?(obj) ? fallback : obj
end
