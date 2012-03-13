window.onerror = (message, file, line) ->
  Flowerbox.contact("log", message)
  Flowerbox.contact("log", "  #{file}:#{line}")

