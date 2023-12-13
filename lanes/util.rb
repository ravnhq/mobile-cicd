# frozen_string_literal: true

# @param [String, NilClass] value
# @param [TrueClass, FalseClass] default
# @return [TrueClass, FalseClass]
def parse_boolean(value, default)
  value = value&.downcase&.strip
  blank?(value) ? default : %w[yes true 1].include?(value)
end

# @param [Object, NilClass] obj
# @return [TrueClass, FalseClass]
def blank?(obj)
  # noinspection RubyNilAnalysis
  return obj.strip.empty? if obj.is_a?(String)

  # noinspection RubyNilAnalysis
  obj.respond_to?(:empty?) ? obj.empty? : !obj
end
