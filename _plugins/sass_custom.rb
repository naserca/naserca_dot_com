require 'sass'

module Sass::Script::Functions
  def random(number)
    Sass::Script::Number.new(rand(number.to_i))
  end
  declare :random, args: [:number]
end