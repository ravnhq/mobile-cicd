# frozen_string_literal: true

# @param [String] value
# @return [TrueClass, FalseClass]
def parse_boolean(value)
  %w[yes true 1].include?(value.downcase.strip)
end

# @param [Object] obj
# @return [TrueClass, FalseClass]
def blank?(obj)
  return obj.strip.empty? if obj.is_a?(String)

  obj.respond_to?(:empty?) ? obj.empty? : !obj
end
