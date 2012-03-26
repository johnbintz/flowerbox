#= require_self
#= require flowerbox/result
#= require flowerbox/exception
#
Flowerbox =
  debug: false
  ping: ->
    Flowerbox.contact('ping')

  messageQueue: []

  contact: (url, data...) ->
    Flowerbox.started = true

    if !Flowerbox.debug
      message = [ url, data ]
      Flowerbox.messageQueue.push(message)

      if Flowerbox.socket
        while Flowerbox.messageQueue.length > 0
          message = Flowerbox.messageQueue.shift()
          Flowerbox.socket.send(JSON.stringify(message))

    if url == 'results'
      if __$instrument?
        Flowerbox.socket.send(JSON.stringify(['instrument', __$instrument]))

      Flowerbox.done = true

  started: false
  done: false

  fail: ->

