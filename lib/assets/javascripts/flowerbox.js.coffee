#= require_self
#= require flowerbox/result
#= require flowerbox/exception
#
Flowerbox =
  debug: false
  ping: ->
    Flowerbox.contact('ping')

  contact: (url, data...) ->
    Flowerbox.started = true
    Flowerbox.done = true if url == 'results'

    if !Flowerbox.debug
      Flowerbox.socket.send(JSON.stringify([ url, data ]))

  started: false
  done: false

  fail: ->

