# frozen_string_literal: true

require "tambo"



def display_hello_world(console)
  width, height = console.size

  # align left center right
  # vertical top middle bottom
  start_x = width / 2 - 7
  start_y = height / 2
  text = Tambo::Text.new("Hello World!", start_x, start_y, console.style)

  start_x = width / 2 - 9
  start_y = height / 2 + 1
  text2 = Tambo::Text.new("Press ESC to exit.", start_x, start_y, console.style)

  console.clear
  console.write(text)
  console.write(text2)
  console.show
end

begin
  console = Tambo::Console.new
  console.style = Tambo::Style.new(color: :magenta, bgcolor: :white)

  display_hello_world(console)

  loop do
    event = console.poll_event

    break if event.key?(Tambo::KEY_ESCAPE)

    display_hello_world(console) if event.resize?
  end
rescue StandardError => e
  Tambo::Logger.backtrace(e)
ensure
  console.close
end
