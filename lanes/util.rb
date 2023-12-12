# @param [String] value
# @param [TrueClass, FalseClass] default
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
