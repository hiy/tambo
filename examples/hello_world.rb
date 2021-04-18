# frozen_string_literal: true

require "tambo"

begin
  console = Tambo::Console.new
  width, height = console.size
  x = width / 2 - 7
  y = height / 2
  text = Tambo::Text.new("Hello World!", x, y)
  console.clear
  console.write(text)
  console.show
  i = 0

  loop do
    event = console.poll_event

    break if event.key?(Tambo::KEY_ESC)

    if event.resize?
      width, height = console.size
      x = width / 2 - 7
      y = height / 2
      text = Tambo::Text.new("Hello World! #{i}", x, y)
      console.clear
      console.write(text)
      console.show
    end

    i += 1
  end
ensure
  console.close
end
