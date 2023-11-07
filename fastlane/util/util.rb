# frozen_string_literal: true

# @param [String] value
# @return [TrueClass, FalseClass]
def parse_boolean(value)
  %w[yes true 1].include?(value.downcase.strip)
end
