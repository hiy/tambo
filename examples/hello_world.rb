# frozen_string_literal: true

require "tambo"

console = Tambo::Console.new
width, height = console.size
text = Tambo::Text.new("Hello World!", width / 2 - 7, height / 2)
console.clear
console.write(text)
console.show

loop do
  event = console.poll_event
  if event.key?(Tambo::KEY_ESC)
    console.close
    break
  end
end
