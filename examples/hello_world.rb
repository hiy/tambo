# frozen_string_literal: true
require "tambo"

console = Tambo::Console.new

width, height = console.size

text = Tambo::Text.new('Hello World', width / 2 - 7, height / 2)

console.clear
console.print(text)

loop do
  event = console.poll_event

  if event.resize?
    console.sync
    console.print(text)
  end

  if event.key?(Tambo::KeyEscape)
    console.close
    break
  end
end

