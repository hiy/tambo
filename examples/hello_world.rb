# frozen_string_literal: true

require "tambo"

console = Tambo::Console.new
width, height = console.size
text = Tambo::Text.new("Hello World!", width / 2 - 7, height / 2)
console.clear
console.write(text)
console.show
