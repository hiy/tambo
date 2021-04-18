# frozen_string_literal: true

require "tambo"

def display_hello_world(console)
  width, height = console.size
  x = width / 2 - 7
  y = height / 2
  text = Tambo::Text.new("Hello World!", x, y)
  console.clear
  console.write(text)
  console.show
end

begin
  console = Tambo::Console.new
  display_hello_world(console)

  loop do
    event = console.poll_event

    break if event.key?(Tambo::KEY_ESC)

    if event.resize?
      display_hello_world(console)
    end
  end
ensure
  console.close
end
