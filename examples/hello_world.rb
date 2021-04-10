# frozen_string_literal: true

require "tambo"
include Tambo

console = Console.new
width, height = console.size
x = width / 2 - 7
y = height / 2
x = 0
y = 3
text = Text.new("Hello World!", x, y)
console.clear
console.write(text)
console.show

i = 0

loop do

  event = console.poll_event

  if event.key?(KEY_ESC)

    text = Text.new("Hello World! #{i}", x, y)
    console.clear
    console.write(text)
    console.show
  end

  i += 1
end


console.close
