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

      Flowerbox.queuePuller() if Flowerbox.socket

  started: false
  done: false

  queuePuller: ->
    if Flowerbox.messageQueue.length > 0
      message = Flowerbox.messageQueue.shift()

      Flowerbox.socket.send JSON.stringify(message), {}, ->
        if message[0] == 'results'
          if __$instrument?
            Flowerbox.socket.send JSON.stringify(['instrument', __$instrument]) {}, ->
              Flowerbox.done = true
          else
            Flowerbox.done = true

        Flowerbox.queuePuller()

  fail: ->

