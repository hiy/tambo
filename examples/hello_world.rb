# frozen_string_literal: true

require "tambo"
include Tambo

console = Console.new
width, height = console.size
text = Text.new("Hello World!", width / 2 - 7, height / 2)
console.clear
console.write(text)
console.show

loop do
  event = console.poll_event

  if event.key?(KEY_ESC)
    console.close
    break
  end
end
